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
    use AssetLib/S4Lite/Datatypes.{UxlSource, SLEquipment, SLEquiLongText, SLEquiCharacteristic};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/GenS4/Patch.{EquipmentPatches};
    use AssetLib/GenS4/S4LiteRelations.{EquiLongText, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Date, S4Int, S4Float};
    use AssetScripts/NonOp/Relations.{PlantEquipWorkItem, EquipmentMapping, InstallationMapping, SiteEastNorth};


    type alias FileSources = 
        { aibReport: XlsxSource
        , equipmentMapping: XlsxSource
        , installationMapping: XlsxSource
        , siteEastNorth: XlsxSource
        }

        /// Split worklist...
                        
    pub def genEquiUxl(srcs: FileSources,   
                        outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* items          = AssetScripts/NonOp/Loader.readPlantEquipWorkItems(srcs.aibReport);
        let* equipMapping   = AssetScripts/NonOp/Loader.readEquipmentMapping(srcs.equipmentMapping);
        let* instMapping    = AssetScripts/NonOp/Loader.readInstallationMapping(srcs.installationMapping);
        let* sitesEN        = AssetScripts/NonOp/Loader.readSiteEastNorth(srcs.siteEastNorth);
        let patchDb         = equipMapping <+> instMapping <+> sitesEN;
        let worklists       = AssetScripts/NonOp/Utils.sublists(50, items);
        let* _              = Result.foldLeftM((ac, xs1) -> genEquiUxl1(ac, patchDb, xs1, outputArgs), 1, worklists);
        Ok()


    def genEquiUxl1(i: Int32, 
                    patchDb: #{EquipmentMapping, InstallationMapping, WorkItem, SiteEastNorth, 
                                EquiCharacteristic, EquipmentPatch | r},
                    xs: List[PlantEquipWorkItem],
                    args: UxlOutputArgs): Result[Int32, String] & Impure = 
        use Result.{flatMap};
        let* equis      = genEquis(patchDb, xs);
        let longTexts   = genLongTexts(xs);
        let chars       = genCharacteristics(patchDb, xs);
        let s4lite      = genS4Lite(equis, longTexts, chars);
        let args1       = AssetScripts/NonOp/Utils.updateArgs(i, args);
        let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(args1, s4lite);
        Ok(i + 1)


    rel EquipmentPatch(plinum: String,
                    category: String,
                    objectType: String,
                    functionalLocation: String)

    rel WorkItem(plinum: String,
                plantTypeDesc: String,              /// e.g. "ANALYSIS LOOP"
                plantEquiTypeDesc: String,          /// e.g. "EQUIPMENT: SPEED/RPM INSTRUMENT"
                parentSainum: String,
                installationSaiNum: String, 
                subinstallationSaiNum: String)

    def makeWorkItems(xs: List[PlantEquipWorkItem]): #{WorkItem | r} = 
        let mkWorkItem1 = x1 -> #{ 
            WorkItem(x1.plinum, x1.plantAssetType, x1.plantEquipAssetType, 
                        x1.parentSainum, x1.installationSainum, x1.subinstallationSainum). 
        };
        List.foldLeft((ac, x1) -> ac <+> mkWorkItem1(x1), #{}, xs)

    def genEquis(patchDb: #{EquipmentMapping, InstallationMapping, WorkItem, EquipmentPatch | r}, 
                    xs: List[PlantEquipWorkItem]): Result[List[SLEquipment], String] & Impure = 
        use Result.flatMap;
        let equis1          = List.map(genEqui1, xs);
        let patches         = genEquipmentPatches(patchDb, xs);
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

    /// LongText - simple functional operation, no Datalog

    def genLongTexts(xs: List[PlantEquipWorkItem]): List[SLEquiLongText] = 
        List.map(genLongText1, xs)


    def genLongText1(x: PlantEquipWorkItem): SLEquiLongText =
        let description = AssetScripts/NonOp/Utils.getShortName(x.processGroupName, x.processName, x.commonName);
        { equiId        = x.plinum
        , description   = description
        , longText      = x.commonName
        }


    def genS4Lite(equis: List[SLEquipment], longTexts: List[SLEquiLongText], chars: Chain[SLEquiCharacteristic]): UxlSource = 
        { funclocs = Chain.empty()
        , funclocLongTexts = Chain.empty()
        , funclocCharacteristics = Chain.empty()
        , equipment = Chain.fromList(equis)
        , equiLongTexts = Chain.fromList(longTexts)
        , equiCharacteristics = chars
        }


    def genEquipmentPatches(db: #{WorkItem, 
                                    EquipmentMapping, InstallationMapping,
                                    EquipmentPatch | r}, 
                            xs: List[PlantEquipWorkItem]) : EquipmentPatches & Impure = 
        let rules = #{
            
            EquipmentPatch(equiId, category, objectType, "${sitefloc}-ACH-ACH-ACH-NON01") :- 
                WorkItem(equiId, plantTypeDesc, plantEquipTypeDesc, _, installationId, "NULL"),
                EquipmentMapping(plantTypeDesc, plantEquipTypeDesc, objectType, _, category),
                InstallationMapping(installationId, sitefloc).
                

            EquipmentPatch(equiId, category, objectType, "${sitefloc}-ACH-ACH-ACH-NON01") :- 
                WorkItem(equiId, plantTypeDesc, plantEquipTypeDesc, _, _, subinstallationId),            
                EquipmentMapping(plantTypeDesc, plantEquipTypeDesc, objectType, _, category),
                InstallationMapping(subinstallationId, sitefloc).

        };
        let workitems = makeWorkItems(xs);
        solve (workitems <+> db <+> rules) project EquipmentPatch
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



    pub def genCharacteristics(db: #{WorkItem, 
                                        InstallationMapping, EquipmentMapping, SiteEastNorth, 
                                        EquiCharacteristic | r},
                                 xs: List[PlantEquipWorkItem]): Chain[SLEquiCharacteristic] & Impure = 
        let rules = #{
            
            /// ${objClass}

            EquiCharacteristic(equiId, objClass, "UNICLASS_CODE", 1, S4String("")) :-
                WorkItem(equiId, plantTypeDesc, plantEquiTypeDesc, _, _, _),
                EquipmentMapping(plantTypeDesc, plantEquiTypeDesc, _, objClass, _).

            EquiCharacteristic(equiId, objClass, "UNICLASS_DESC", 1, S4String("")) :-
                WorkItem(equiId, plantTypeDesc, plantEquiTypeDesc, _, _, _),
                EquipmentMapping(plantTypeDesc, plantEquiTypeDesc, _, objClass, _).

            /// AIB_REFERENCE

            EquiCharacteristic(equiId, "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
                WorkItem(equiId, _, _, _, _, _).

            EquiCharacteristic(equiId, "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(equiId)) :-
                WorkItem(equiId, _, _, _, _, _).

            EquiCharacteristic(equiId, "AIB_REFERENCE", "AI2_AIB_REFERENCE", 2, S4String(equiId)) :-
                WorkItem(equiId, _, _, _, _, _).                

            /// EAST_NORTH

            EquiCharacteristic(equiId, "EAST_NORTH", "EASTING", 1, S4Int(easting)) :-
                WorkItem(equiId, _, _, _, installationId, "NULL"),
                InstallationMapping(installationId, s4SiteFloc),
                SiteEastNorth(s4SiteFloc, easting, _).

            EquiCharacteristic(equiId, "EAST_NORTH", "EASTING", 1, S4Int(easting)) :-
                WorkItem(equiId, _, _, _, _, subinstallationId),
                InstallationMapping(subinstallationId, s4SiteFloc),
                SiteEastNorth(s4SiteFloc, easting, _).

            EquiCharacteristic(equiId, "EAST_NORTH", "NORTHING", 1, S4Int(northing)) :-
                WorkItem(equiId, _, _, _, installationId, "NULL"),
                InstallationMapping(installationId, s4SiteFloc),
                SiteEastNorth(s4SiteFloc, _, northing).

            EquiCharacteristic(equiId, "EAST_NORTH", "NORTHING", 1, S4Int(northing)) :-
                WorkItem(equiId, _, _, _, _, subinstallationId),
                InstallationMapping(subinstallationId, s4SiteFloc),
                SiteEastNorth(s4SiteFloc, _, northing).           

        };
        let workitems = makeWorkItems(xs);
        solve (workitems <+> db <+> rules) project EquiCharacteristic
            |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic





}
