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

    use AssetLib/S4Lite/Datatypes.{SLFunctionalLocation};
    use AssetLib/GenS4/S4LiteRelations.{FunctionalLocation, FlocCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String};
    use AssetLib/GenS4/WorkLists.{FlocWorkItemRec, FlocWorkItem};



    /// Also the FunctionalLocation rule doesn't really benefit being written in Datalog.
    /// It is a simple (deterministic) type change
    pub def genFlocs(workitems: #{FlocWorkItem, FunctionalLocation | r1}): #{FunctionalLocation | r} = 
        let rules = #{
            FunctionalLocation(funcloc, 
                        String.takeLeft(40, description),
                        structureInd,
                        objectType,
                        installedFrom,
                        level >= 5,
                        "UCON") :- 
                FlocWorkItem(funcloc, description, level, _, installedFrom, structureInd, objectType, _, _,  _, _).
        };
        solve (rules <+> workitems) project FunctionalLocation

    pub def genFloc1(x: FlocWorkItemRec): Result[SLFunctionalLocation, String] = 
        use Result.flatMap;
        let* floc   = AssetLib/Base/S4/Floc.new(x.funcloc);
        let level   = AssetLib/Base/S4/Floc.level(floc);
        let super   = AssetLib/Base/S4/Floc.parent(floc) |> Option.map(ToString.toString) |> flip(Option.getWithDefault, "");        
        Ok( { funcloc               = x.funcloc
            , description           = x.description
            , category              = level
            , structureIndicator    = x.structureIndicator
            , objectType            = x.objectType
            , startupDate           = x.installedFrom
            , superiorFloc          = super
            , equipmentInstall      = equipmentInstall(x.structureIndicator, level)
            , status                = "UCON"
            })

    def equipmentInstall(structure: String, level: Int32): Bool = match structure {
        case "YW-GS" if level >= 5 => true
        case "YW-ES" if level >= 3 => true
        case _ => false
    }



    pub def flocCharacteristics1(workitems: #{FlocWorkItem, FlocCharacteristic | r}): #{FlocCharacteristic | r} = 
        let rules = #{
            FlocCharacteristic(funcloc, "UNICLASS_CODE", "UNICLASS_CODE", 1, S4String("")) :- 
                FlocWorkItem(funcloc, _, level, _, _, _, _, _, _, _, _),
                if level != 5.

            FlocCharacteristic(funcloc, "UNICLASS_CODE", "UNICLASS_DESC", 1, S4String("")) :- 
                FlocWorkItem(funcloc, _, level, _, _, _, _, _, _, _, _),
                if level != 5.

            FlocCharacteristic(funcloc, className, "SYSTEM_TYPE", 1, S4String(systemDescr)) :- 
                FlocWorkItem(funcloc, _, level, _, _, _, _, className, systemDescr, _, _),
                if level == 5.
        };
        solve (rules <+> workitems) project FlocCharacteristic

}

