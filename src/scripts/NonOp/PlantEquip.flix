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
    use AssetLib/S4Lite/Datatypes.{UxlSource, SLEquipment};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/GenS4/S4LiteRelations.{EquiLongText, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Date, S4Int, S4Float};
    use AssetScripts/NonOp/Relations.{PlantEquipWorkItem};



        /// Split worklist...
                        
    pub def genEquiUxl(src: XlsxSource,   
                        args: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* items      = AssetScripts/NonOp/Loader.readPlantEquipWorkItems(src);
        let worklists   = AssetScripts/NonOp/Utils.sublists(50, items);
        let* _          = Result.foldLeftM((ac, xs1) -> genEquiUxl1(ac, xs1, args), 1, worklists);
        Ok()


    def genEquiUxl1(i: Int32, 
                    xs: List[PlantEquipWorkItem],
                    args: UxlOutputArgs): Result[Int32, String] & Impure = 
        use Result.{flatMap};
        let* equis      = genEquis(xs);
        let s4lite      = genS4Lite(equis);
        let args1       = AssetScripts/NonOp/Utils.updateArgs(i, args);
        let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(args1, s4lite);
        Ok(i + 1)


    pub def genEquis(xs: List[PlantEquipWorkItem]): Result[List[SLEquipment], String] & Impure = 
        let today = Time/LocalDate.now();
        List.map(genEqui1(today), xs)  |> Ok


    def genEqui1(today: Time.LocalDate, x: PlantEquipWorkItem): SLEquipment =
        { equiId                = x.plinum
        , category              = ""
        , description           = AssetScripts/NonOp/Utils.getShortName(x.processGroupName, x.processName, x.commonName)
        , validFrom             = today         /// Should remain `today`.
        , objectType            = x.assetType
        , weightKg              = None
        , startupDate           = Option.getWithDefault(x.installedFromDate, today)
        , manufacturer          = x.manufacturer
        , model                 = x.model
        , partNumber            = ""
        , serialNumber          = ""
        , functionalLocation    = "BAD01-UNKNOWN"
        , superOrdinateEqui     = ""
        , position              = None
        , techIdentNo           = ""
        , status                = "NOP"
        }


    /// rel OptionalPandITag(equiId: String, tag: String)
    /// rel HasPandITag(equiId: String)

    /// def genEqui(today: Time.LocalDate, 
    ///                 db: #{SuperEquipWorkItem, GrandParentParentNames,
    ///                         AssetTypeDescription, EquipmentMapping, EquipProperties, InstallationMapping, PandITag,
    ///                         OptionalPandITag, HasPandITag,
    ///                         EquiLongText, EquiCharacteristic | r}): #{EquiLongText, EquiCharacteristic | r} = 
    ///     use AssetScripts/NonOp/Utils.{getShortName};
    ///     let noneI32: Option[Int32] = None;
    ///     let noneF64: Option[Float64] = None;
    ///     let rules = #{
        
    ///         Equipment(equiId, 
    ///                     category,
    ///                     getShortName(procGroupName, procName, commonName),
    ///                     today,
    ///                     objectType,
    ///                     noneF64,
    ///                     Option.getWithDefault(installedFromDate, defaultDate()),
    ///                     manufacturer,
    ///                     model,
    ///                     "",
    ///                     "",
    ///                     "${sitefloc}-ACH-ACH-ACH-NON01",        /// functionalLocation
    ///                     "",                                     /// superOrdinateEqui
    ///                     noneI32,                                /// position
    ///                     techIdentNo,
    ///                     "NOP") :- 
    ///             SuperEquipWorkItem(equiId, commonName, aibInstRef),
    ///             AssetTypeDescription(equiId, plantTypeDesc, plantEquiTypeDesc),                
    ///             GrandParentParentNames(equiId, procGroupName, procName),
    ///             EquipmentMapping(plantTypeDesc, plantEquiTypeDesc, objectType, _, category), 
    ///             EquipProperties(equiId, manufacturer, model, installedFromDate),
    ///             InstallationMapping(aibInstRef, sitefloc),
    ///             OptionalPandITag(equiId, techIdentNo).

    ///         /// Multilingual text

    ///         OptionalPandITag(equiId, tag) :- 
    ///             SuperEquipWorkItem(equiId, _, _),
    ///             PandITag(equiId, tag).
            
    ///         OptionalPandITag(equiId, "") :- 
    ///             SuperEquipWorkItem(equiId, _, _),
    ///             not HasPandITag(equiId).

    ///         HasPandITag(equiId) :- PandITag(equiId, _).

    ///         EquiLongText(equiId, getShortName(procGroupName, procName, commonName), commonName) :- 
    ///             SuperEquipWorkItem(equiId, commonName, _),
    ///             GrandParentParentNames(equiId, procGroupName, procName).

    ///         /// Characteristics

    ///         EquiCharacteristic(equiId, oclass, "UNICLASS_CODE", 1, S4String("")) :-
    ///             SuperEquipWorkItem(equiId, _, _),
    ///             AssetTypeDescription(equiId, plantTypeDesc, plantEquiTypeDesc),
    ///             EquipmentMapping(plantTypeDesc, plantEquiTypeDesc, _, oclass, _).

    ///         EquiCharacteristic(equiId, oclass, "UNICLASS_DESC", 1, S4String("")) :-
    ///             SuperEquipWorkItem(equiId, _, _),
    ///             AssetTypeDescription(equiId, plantTypeDesc, plantEquiTypeDesc),
    ///             EquipmentMapping(plantTypeDesc, plantEquiTypeDesc, _, oclass, _).

    ///     };
    ///     solve (db <+> rules) project Equipment, EquiLongText, EquiCharacteristic

    /// def defaultDate(): Time.LocalDate = Time/LocalDate.new({year = 1970, month = 1, dayOfMonth = 1})

    def genS4Lite(equis: List[SLEquipment]): UxlSource = 
        { funclocs = Monoid.empty()
        , funclocLongTexts = Monoid.empty()
        , funclocCharacteristics = Monoid.empty()
        , equipment = Chain.fromList(equis)
        , equiLongTexts = Monoid.empty()
        , equiCharacteristics = Monoid.empty()
        }

}
