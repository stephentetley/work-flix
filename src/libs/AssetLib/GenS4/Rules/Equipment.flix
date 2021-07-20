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


    /// TODO - patching `EquipmentAttributes`
    pub def genEquis(attribs: List[EquipmentAttributes],
                        xs: List[EquiWorkItemRec]): Result[List[SLEquipment], String] & Impure = 
        let mm = makePatches(attribs);
        let today = Time/LocalDate.now();
        List.map(genEqui1(today), xs) 
            |> Result.traverse(patch(mm))


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

    def patch(mm: MutMap[String, SLEquipment -> SLEquipment], 
                equi: SLEquipment): Result[SLEquipment, String] & Impure = 
        use Result.flatMap;
        let* fn = Option.toOk(MutMap.get(equi.equiId, mm), "cannot patch ${equi.equiId}");
        Ok(fn(equi))


    def makePatches(xs: List[EquipmentAttributes]): MutMap[String, SLEquipment -> SLEquipment] & Impure = 
        let mm = MutMap.empty();
        let ins1 = row -> { 
            let update: SLEquipment -> SLEquipment = makePatch1(row);
            MutMap.put!(row.aibref, update, mm)            
        }; 
        List.foreach(ins1, xs);
        mm


    def makePatch1(attribs: EquipmentAttributes, x: SLEquipment): SLEquipment =
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
        , status                = s4Status(attribs.status)
        }

    def s4Status(x: String): String = match x {
        case "OPERATIONAL" =>  "OPER"
        case "NON OPERATIONAL" => "NOP"
        case _ => x
    }

    pub rel WorkItem(equiId: String, s4ClassId: String) 

    pub def makeWorkItems(xs: List[EquiWorkItemRec]): #{WorkItem | r} = 
        let makeRel = row -> #{ WorkItem(row.equipmentId, row.s4EquiClass). };
        List.foldLeft((ac, x1) -> ac <+> makeRel(x1), #{}, xs)

    pub def equiCharacteristics1(input: #{WorkItem,
                                            LocationOnSite,  EquiCharacteristic| r1}): #{EquiCharacteristic | r} =
        let rules = #{
            
            EquiCharacteristic(equiId, s4EquiClass, "UNICLASS_CODE", 1, S4String("")) :- 
                WorkItem(equiId, s4EquiClass).

            EquiCharacteristic(equiId, s4EquiClass, "UNICLASS_DESC", 1, S4String("")) :-
                WorkItem(equiId, s4EquiClass).

            EquiCharacteristic(equiId, s4EquiClass, "LOCATION_ON_SITE", 1, S4String(s4Location(location))) :-
                WorkItem(equiId, s4EquiClass),
                LocationOnSite(equiId, location).

        };
        solve (rules <+> input) project EquiCharacteristic


    def s4Location(s: String): String =
        if (String.length(s) > 30) "SEE LONG TEXT" else s


}

