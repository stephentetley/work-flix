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
    use AssetLib/GenS4/S4LiteRelations.{FlocCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String};
    use AssetLib/GenS4/WorkLists.{FlocWorkItem};



    pub def genFlocs(workitems: List[FlocWorkItem]): Result[List[SLFunctionalLocation], String] = 
        Result.traverse(genFloc1, workitems)

    def genFloc1(x: FlocWorkItem): Result[SLFunctionalLocation, String] = 
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

    pub def genFlocCharacteristics1(worklist: List[FlocWorkItem]): Result[Chain[SLFlocCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = makeFlocWorkItem4s(worklist);
        let ans         = flocCharacteristics1(workitems) |> AssetLib/GenS4/S4LiteRelations.toSLFlocCharacteristic;
        Ok(ans) 

    /// Case specific WorkItem...
    pub rel FlocWorkItem4(floc: String, level: Int32, systemClass: String, systemDescription: String)


    def makeFlocWorkItem4s(xs: List[FlocWorkItem]): #{FlocWorkItem4 | r}  = 
        List.foldLeft((ac, x) -> ac <+> #{ FlocWorkItem4(x.funcloc, x.level, x.systemClass, x.systemTypeDescription). }, #{}, xs)


    pub def flocCharacteristics1(input: #{FlocWorkItem4, FlocCharacteristic | r}): #{FlocCharacteristic | r} = 
        let rules = #{
            FlocCharacteristic(funcloc, "UNICLASS_CODE", "UNICLASS_CODE", 1, S4String("")) :- 
                FlocWorkItem4(funcloc, level, _, _),
                if level != 5.

            FlocCharacteristic(funcloc, "UNICLASS_CODE", "UNICLASS_DESC", 1, S4String("")) :- 
                FlocWorkItem4(funcloc, level, _, _),
                if level != 5.

            FlocCharacteristic(funcloc, className, "SYSTEM_TYPE", 1, S4String(systemDescr)) :- 
                FlocWorkItem4(funcloc, level, className, systemDescr),
                if level == 5.
        };
        solve (rules <+> input) project FlocCharacteristic

}

