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


namespace AssetLib/GenS4/Patch {


    use AssetLib/GenS4/AibFacts/Attributes/Equipment.{EquipmentAttributes};
    use AssetLib/S4Lite/Datatypes.{SLEquipment};

    /// TODO can we use RelLib/Relation.Organization instead?
    /// Also can patches be first-order, rather than update functions?

    pub type alias EquipmentPatches = Map[String, SLEquipment -> SLEquipment]

    pub def softPatchEquipment(patches: EquipmentPatches, xs: List[SLEquipment]): List[SLEquipment] = 
        let fn = x1 -> match patchEquipment1(patches, x1) {
            case Ok(a1) => a1
            case Err(_) => x1
        };
        List.map(fn, xs)

    pub def patchEquipment(patches: EquipmentPatches, xs: List[SLEquipment]): Result[List[SLEquipment], String] = 
        Result.traverse(patchEquipment1(patches), xs)


    def patchEquipment1(patches: EquipmentPatches, equi: SLEquipment): Result[SLEquipment, String] = 
        use Result.flatMap;
        let* fn = Option.toOk(Map.get(equi.equiId, patches), "cannot patch ${equi.equiId}");
        Ok(fn(equi))

    /// TODO should this load its data from file rather than take a list?
    pub def makeEquipmentAttributesPatches(xs: List[EquipmentAttributes]): EquipmentPatches = 
        let ins1 = (ac, row) -> { 
            let update: SLEquipment -> SLEquipment = makePatch1(row);
            Map.insert(row.aibref, update, ac)            
        }; 
        List.foldLeft(ins1, Map.empty(), xs)


    def makePatch1(attribs: EquipmentAttributes, x: SLEquipment): SLEquipment =
        { equiId                = x.equiId
        , category              = x.category
        , description           = x.description
        , validFrom             = x.validFrom
        , objectType            = x.objectType
        , weightKg              = attribs.weightKg
        , startupDate           = attribs.installedFrom
        , manufacturer          = x.manufacturer
        , model                 = x.model
        , partNumber            = attribs.specificModelFrame
        , serialNumber          = if (not String.isEmpty(attribs.serialNumber)) attribs.serialNumber else "UNKNOWN"
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


}
