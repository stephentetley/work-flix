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

namespace AssetLib/Gens4/Rules/FunctionalLocation {

    use AssetLib/S4Lite/Datatypes.{SLFunctionalLocation, SLFlocCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{FlocWorkItem};



    pub def genFlocs(workitems: List[FlocWorkItem]): GenMonad[Unit] = 
        AssetLib/GenS4/GenMonad.mapX(genFloc1, workitems)

    def genFloc1(x: FlocWorkItem): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, liftActionResult, tellSLFunctionalLocation};
        let* floc   = liftActionResult(_ -> AssetLib/Base/S4/Floc.new(x.funcloc) as & Impure);
        let level   = AssetLib/Base/S4/Floc.level(floc);
        let super   = AssetLib/Base/S4/Floc.parent(floc) |> Option.map(ToString.toString) |> Option.getWithDefault("");
        tellSLFunctionalLocation( { funcloc               = x.funcloc
            , description           = x.description
            , category              = level
            , structureIndicator    = x.structureIndicator
            , objectType            = x.objectType
            , startupDate           = x.installedFrom
            , position              = x.position
            , superiorFloc          = super
            , equipmentInstall      = getEquipmentInstall(x.structureIndicator, level)
            , status                = "UCON"
            })

    def getEquipmentInstall(structure: String, level: Int32): Bool = match structure {
        case "YW-GS" if level >= 5 => true
        case "YW-ES" if level >= 3 => true
        case _ => false
    }

    pub def genFlocCharacteristics(worklist: List[FlocWorkItem]): GenMonad[Unit] =
        use Result.{flatMap};
        let make1       = x1 -> #{ FlocWorkItem4(x1.funcloc, x1.level, x1.systemClass, x1.systemTypeDescription). };        
        let workitems   = RelLib/Relation.foldMap(make1, worklist);
        flocCharacteristics(workitems)

    /// Case specific WorkItem...
    pub rel FlocWorkItem4(floc: String, level: Int32, systemClass: String, systemDescription: String)


    pub def flocCharacteristics(input: #{FlocWorkItem4, FlocCharacteristic | r}): GenMonad[Unit] = 
        let rules = #{
            FlocCharacteristic(funcloc, "UNICLASS_CODE", "UNICLASS_CODE", S4String("")) :- 
                FlocWorkItem4(funcloc, level, _, _),
                if level != 5.

            FlocCharacteristic(funcloc, "UNICLASS_CODE", "UNICLASS_DESC", S4String("")) :- 
                FlocWorkItem4(funcloc, level, _, _),
                if level != 5.

            FlocCharacteristic(funcloc, className, "SYSTEM_TYPE", S4String(systemDescr)) :- 
                FlocWorkItem4(funcloc, level, className, systemDescr),
                if level == 5.
        };
        AssetLib/GenS4/GenMonad.tellFlocCharacteristics(rules <+> input)

}

