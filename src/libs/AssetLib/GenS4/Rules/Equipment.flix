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

    use AssetLib/AibFacts/Attributes/Equipment.{EquipmentAttributes};
    use AssetLib/AibFacts/Attributes/LocationData.{LocationOnSite};
    use AssetLib/S4Lite/Datatypes.{SLEquipment};
    use AssetLib/GenS4/WorkLists.{EquiWorkItemRec, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{Equipment, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String};


    /// TODO remove today...
    /// Also the Equipment rule doesn't really benefit being written in Datalog.
    pub def genEquis(today: Time.LocalDate, 
                        input: #{EquiWorkItem, EquipmentAttributes, Equipment | r1}): #{Equipment | r} = 
        let rules = #{
            Equipment(aibref, 
                        s4Category,
                        String.takeLeft(40, s4Name),
                        today,
                        s4EquiType,
                        weightKg,
                        installedFrom,
                        manufacturer,
                        model,
                        specificModelFrame,
                        s4SerialNumber(serialNumber),
                        suppliedFloc,
                        superEqui,
                        position,
                        pandiTag,
                        s4Status(status)) :- 
                EquiWorkItem(aibref, s4Name, suppliedFloc, superEqui, _, position, s4Category, s4EquiType, _), 
                EquipmentAttributes(aibref, installedFrom, manufacturer, model, status, pandiTag, serialNumber, specificModelFrame, weightKg).
        };
        solve (rules <+> input) project Equipment

    /// TODO patching `EquipmentAttributes`
    pub def genEquisNEW(today: Time.LocalDate, xs: List[EquiWorkItemRec]): Result[SLEquipment, String] = 
        List.map(genEqui1(today), xs) 
            |> Ok


    def genEqui1(today: Time.LocalDate, x: EquiWorkItemRec): SLEquipment =
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


    type alias EquipmentAttributesRec = 
        { aibref: String
        , installedFrom: Time.LocalDate
        , manufacturer: String
        , model: String
        , status: String
        , pandiTag: String
        , serialNumber: String
        , specificModelFrame: String
        , weightKg: Option[Float64]
        }

    pub def patch1(attribs: EquipmentAttributesRec, x: SLEquipment): SLEquipment =
        { equiId                = x.equiId
        , category              = x.category
        , description           = x.description
        , validFrom             = x.validFrom
        , objectType            = x.objectType
        , weightKg              = attribs.weightKg
        , startupDate           = attribs.installedFrom
        , manufacturer          = attribs.manufacturer
        , model                 = attribs.model
        , partNumber            = attribs.specificModelFrame
        , serialNumber          = attribs.serialNumber
        , functionalLocation    = x.functionalLocation
        , superOrdinateEqui     = x.superOrdinateEqui
        , position              = x.position
        , techIdentNo           = attribs.pandiTag
        , status                = attribs.status
        }

    pub def equiCharacteristics1(input: #{EquiWorkItem, EquiCharacteristic, 
                                            LocationOnSite | r1}): #{EquiCharacteristic | r} =
        let rules = #{
            
            EquiCharacteristic(equiId, s4EquiClass, "UNICLASS_CODE", 1, S4String("")) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, s4EquiClass).

            EquiCharacteristic(equiId, s4EquiClass, "UNICLASS_DESC", 1, S4String("")) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, s4EquiClass).

            EquiCharacteristic(equiId, s4EquiClass, "LOCATION_ON_SITE", 1, S4String(s4Location(location))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, s4EquiClass),
                LocationOnSite(equiId, location).

        };
        solve (rules <+> input) project EquiCharacteristic


    def s4Location(s: String): String =
        if (String.length(s) > 30) "SEE LONG TEXT" else s

    def s4Status(x: String): String = match x {
        case "OPERATIONAL" =>  "OPER"
        case "NON OPERATIONAL" => "NOP"
        case _ => x
    }

    def s4SerialNumber(s: String): String = match s { 
        case "N/A" => "NOT APPLICABLE"
        case s1 if (String.isEmpty(s1)) => "UNKNOWN"
        case s1 => s1
    }

}

