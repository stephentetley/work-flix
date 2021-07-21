/*
 * Copyright 2021 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


namespace AssetScripts/NonOp/PlantEquip {

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/S4Lite/Datatypes.{UxlSource, SLEquipment, SLEquiLongText};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/GenS4/Patch.{EquipmentPatches};
    use AssetLib/GenS4/S4LiteRelations.{EquiLongText, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Date, S4Int, S4Float};
    use AssetScripts/NonOp/Relations.{PlantEquipWorkItem, EquipmentMapping, InstallationMapping};


    type alias FileSources = 
        { aibReport: XlsxSource
        , equipmentMapping: XlsxSource
        , installationMapping: XlsxSource
        }

        /// Split worklist...
                        
    pub def genEquiUxl(srcs: FileSources,   
                        outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* items          = AssetScripts/NonOp/Loader.readPlantEquipWorkItems(srcs.aibReport);
        let* equipMapping   = AssetScripts/NonOp/Loader.readEquipmentMapping(srcs.equipmentMapping);
        let* instMapping    = AssetScripts/NonOp/Loader.readInstallationMapping(srcs.installationMapping);
        let patchDb         = equipMapping <+> instMapping;
        let worklists       = AssetScripts/NonOp/Utils.sublists(50, items);
        let* _              = Result.foldLeftM((ac, xs1) -> genEquiUxl1(ac, patchDb, xs1, outputArgs), 1, worklists);
        Ok()


    def genEquiUxl1(i: Int32, 
                    patchDb: #{EquipmentMapping, InstallationMapping, WorkItemForPatch, EquipmentPatch | r},
                    xs: List[PlantEquipWorkItem],
                    args: UxlOutputArgs): Result[Int32, String] & Impure = 
        use Result.{flatMap};
        let* equis      = genEquis(patchDb, xs);
        let longTexts   = genLongTexts(xs);
        let s4lite      = genS4Lite(equis, longTexts);
        let args1       = AssetScripts/NonOp/Utils.updateArgs(i, args);
        let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(args1, s4lite);
        Ok(i + 1)


    rel EquipmentPatch(plinum: String,
                    category: String,
                    objectType: String,
                    functionalLocation: String)

    rel WorkItemForPatch(plinum: String,
                        plantTypeDesc: String,              /// e.g. "ANALYSIS LOOP"
                        plantEquiTypeDesc: String,          /// e.g. "EQUIPMENT: SPEED/RPM INSTRUMENT"
                        installationSaiNum: String, 
                        subinstallationSaiNum: String)

    def genEquis(patchDb: #{EquipmentMapping, InstallationMapping, WorkItemForPatch, EquipmentPatch | r}, 
                    xs: List[PlantEquipWorkItem]): Result[List[SLEquipment], String] & Impure = 
        use Result.flatMap;
        let mkWorkItemRel   = x1 -> #{ 
            WorkItemForPatch(x1.plinum, x1.plantAssetType, x1.plantEquipAssetType, 
                            x1.installationSainum, x1.subinstallationSainum). 
        };
        let workItemRels    = List.foldLeft((ac, x1) -> ac <+> mkWorkItemRel(x1), #{}, xs);
        let equis1          = List.map(genEqui1, xs);
        let patches         = genEquipmentPatches(patchDb <+> workItemRels);
        AssetLib/GenS4/Patch.softPatchEquipment(patches, equis1) |> Ok


    def genEqui1(x: PlantEquipWorkItem): SLEquipment & Impure =
        let today = Time/LocalDate.now();
        let defaultDate = Time/LocalDate.new({year = 1970, month = 1, dayOfMonth = 1});
        let noWeight: Option[Float64] = None;
        let noPosition: Option[Int32] = None;
        let description = AssetScripts/NonOp/Utils.getShortName(x.processGroupName, x.processName, x.commonName);
        { equiId                = x.plinum
        , category              = "Bad: ${x.plinum}"
        , description           = description
        , validFrom             = today         /// Should remain `today`.
        , objectType            = x.plantEquipAssetType
        , weightKg              = noWeight
        , startupDate           = Option.getWithDefault(x.installedFromDate, defaultDate)
        , manufacturer          = x.manufacturer
        , model                 = x.model
        , partNumber            = ""
        , serialNumber          = ""
        , functionalLocation    = "Bad: ${x.installationSainum}"
        , superOrdinateEqui     = ""
        , position              = noPosition
        , techIdentNo           = ""
        , status                = "NOP"
        }

    /// LongText

    def genLongTexts(xs: List[PlantEquipWorkItem]): List[SLEquiLongText] = 
        List.map(genLongText1, xs)


    def genLongText1(x: PlantEquipWorkItem): SLEquiLongText =
        let description = AssetScripts/NonOp/Utils.getShortName(x.processGroupName, x.processName, x.commonName);
        { equiId        = x.plinum
        , description   = description
        , longText      = x.commonName
        }





    def genS4Lite(equis: List[SLEquipment], longTexts: List[SLEquiLongText]): UxlSource = 
        { funclocs = Chain.empty()
        , funclocLongTexts = Chain.empty()
        , funclocCharacteristics = Chain.empty()
        , equipment = Chain.fromList(equis)
        , equiLongTexts = Chain.fromList(longTexts)
        , equiCharacteristics = Chain.empty()
        }


    def genEquipmentPatches(db: #{WorkItemForPatch, 
                                        EquipmentMapping, InstallationMapping,
                                        EquipmentPatch | r}) : EquipmentPatches & Impure = 
        let rules = #{
            
            EquipmentPatch(equiId, category, objectType, "${sitefloc}-ACH-ACH-ACH-NON01") :- 
                WorkItemForPatch(equiId, plantTypeDesc, plantEquipTypeDesc, installationId, "NULL"),
                EquipmentMapping(plantTypeDesc, plantEquipTypeDesc, objectType, _, category),
                InstallationMapping(installationId, sitefloc).
                

            EquipmentPatch(equiId, category, objectType, "${sitefloc}-ACH-ACH-ACH-NON01") :- 
                WorkItemForPatch(equiId, plantTypeDesc, plantEquipTypeDesc, _, subinstallationId),            
                EquipmentMapping(plantTypeDesc, plantEquipTypeDesc, objectType, _, category),
                InstallationMapping(subinstallationId, sitefloc).

        };
        solve (db <+> rules) project EquipmentPatch
            |> makeEquipmentPatches



    def makeEquipmentPatches(relns: #{EquipmentPatch | r}): EquipmentPatches & Impure = 
        let mm = MutMap.empty();
        let insert1 = row -> { 
            let (equiId, category, objType, funcLoc) = row;
            let update: SLEquipment -> SLEquipment = makePatch1(category, objType, funcLoc);
            MutMap.put!(equiId, update, mm)            
        }; 
        query relns select (w,x,y,z) from EquipmentPatch(w,x,y,z) 
            |> Array.foreach(insert1);
        mm


    def makePatch1(category: String, objType: String, funcLoc: String, r1: SLEquipment): SLEquipment =
        {category = category, objectType = objType, functionalLocation = funcLoc | r1}







    /// Characteristics

    ///         EquiCharacteristic(equiId, oclass, "UNICLASS_CODE", 1, S4String("")) :-
    ///             SuperEquipWorkItem(equiId, _, _),
    ///             AssetTypeDescription(equiId, plantTypeDesc, plantEquiTypeDesc),
    ///             EquipmentMapping(plantTypeDesc, plantEquiTypeDesc, _, oclass, _).

    ///         EquiCharacteristic(equiId, oclass, "UNICLASS_DESC", 1, S4String("")) :-
    ///             SuperEquipWorkItem(equiId, _, _),
    ///             AssetTypeDescription(equiId, plantTypeDesc, plantEquiTypeDesc),
    ///             EquipmentMapping(plantTypeDesc, plantEquiTypeDesc, _, oclass, _).

    ///     };


}
