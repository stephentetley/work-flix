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

namespace AssetLib/GenS4/Rules/Equipment {

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/GenS4/AibFacts/Attributes/Equipment.{EquipmentAttributes};
    use AssetLib/GenS4/AibFacts/Attributes/LocationData.{LocationOnSite};
    use AssetLib/S4Lite/Datatypes.{SLEquipment, SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{Equipment, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String};
    use AssetLib/GenS4/Rules/Characteristics/CommonRelations.{EquiWorkItem3};


    /// # Equipment


    pub def genEquis(attribs: List[EquipmentAttributes], xs: List[EquiWorkItem]): Result[List[SLEquipment], String] & Impure = 
        let patches = AssetLib/GenS4/Patch.makeEquipmentAttributesPatches(attribs);
        let today = Time/LocalDate.now();
        List.map(genEqui1(today), xs) 
            |> AssetLib/GenS4/Patch.patchEquipment(patches)


    def genEqui1(today: Time.LocalDate, x: EquiWorkItem): SLEquipment =
        { equiId                = x.equipmentId
        , category              = x.s4Category              /// e.g "M", "I", "E"
        , description           = String.takeLeft(40, x.s4Name)
        , validFrom             = today         /// Should remain `today`.
        , objectType            = x.s4EquiType
        , weightKg              = None
        , startupDate           = today         /// Should be "patched"
        , manufacturer          = "TO BE DETERMINED"
        , model                 = "TO BE DETERMINED"
        , partNumber            = ""
        , serialNumber          = "UNKNOWN"
        , functionalLocation    = x.s4Floc
        , superOrdinateEqui     = x.superEquiId
        , position              = x.position
        , techIdentNo           = ""
        , status                = "UCON"
        }


    
    /// # Characteristics
    /// src should be valve facts
    pub def genCommonCharacteristics(worklist: List[EquiWorkItem], locationSrc: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(worklist);
        let* facts      = AssetLib/GenS4/AibFacts/Attributes/LocationData.readLocationOnSiteData(locationSrc);
        let ans         = equiCommonCharacteristics(workitems <+> facts);
        Ok(ans) 



    pub def equiCommonCharacteristics(input: #{EquiWorkItem3,
                                            LocationOnSite,  EquiCharacteristic| r1}): Chain[SLEquiCharacteristic] & Impure =
        let rules = #{
            
            EquiCharacteristic(equiId, s4EquiClass, "UNICLASS_CODE", 1, S4String("")) :- 
                EquiWorkItem3(equiId, _, s4EquiClass).

            EquiCharacteristic(equiId, s4EquiClass, "UNICLASS_DESC", 1, S4String("")) :-
                EquiWorkItem3(equiId, _, s4EquiClass).

            EquiCharacteristic(equiId, s4EquiClass, "LOCATION_ON_SITE", 1, S4String(s4Location(location))) :-
                EquiWorkItem3(equiId, _, s4EquiClass),
                LocationOnSite(equiId, location).

        };
        solve (rules <+> input) project EquiCharacteristic 
            |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic


    def s4Location(s: String): String =
        if (String.length(s) > 30) "SEE LONG TEXT" else s


}

