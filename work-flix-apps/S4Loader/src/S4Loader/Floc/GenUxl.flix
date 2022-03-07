/*
 * Copyright 2022 Stephen Tetley
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

namespace S4Loader/Floc/GenUxl {
    
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/S4Lite/Datatypes.{UxlOutput, SLFunctionalLocation};
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic};

    use S4Loader/Floc/Gen/WorkList.{FlocWorkItemRow};

    /// Returns a Map of the batches - may be sparse.
    pub def genFlocUxlBatches(worklist: XlsxSource): Result[Map[Int32, UxlOutput], String] & Impure =
        use Result.{flatMap};
        let* workitems      = S4Loader/Floc/Gen/WorkList.readFlocWorkList(worklist);
        let groups          = List.foldLeft((m, x1) -> Map.insertWith(Chain.append, x1.batchNumber, Chain.singleton(x1), m), 
                                            Map.empty(), workitems);
        let output          = Map.map(Chain.toList >> genUxl1, groups);
        Ok(output)
    
    
    def genUxl1(workitems: List[FlocWorkItemRow]): UxlOutput & Impure =
        let flocs           = List.map(genSLFunctionalLocation, workitems) |> List.toChain;
        let r1              = S4Loader/Floc/Gen/WorkList.genFlocWorkItems(workitems);
        let r2              = S4Loader/Floc/Gen/WorkList.genProperties(workitems);
        let db              = r1 <+> r2 <+> S4Loader/Floc/Rules/FlocCharacteristics.flocCharacteristics();
        let flocChars       = (solve db project FlocCharacteristic) |> AssetLib/S4Lite/S4LiteRelations.toSLFlocCharacteristics;
        let uxl             = AssetLib/S4Lite/Datatypes.emptyUxlOutput();
        {funclocs = flocs, funclocCharacteristics = flocChars | uxl}



    def genSLFunctionalLocation(x: FlocWorkItemRow): SLFunctionalLocation = 
        let floc    = AssetLib/Base/S4/Floc.new1(x.funcloc);
        let level   = AssetLib/Base/S4/Floc.level(floc);
        let parent  = AssetLib/Base/S4/Floc.parent(floc) |> Option.map(ToString.toString) |> Option.getWithDefault("");
        { funcloc               = x.funcloc
        , description           = x.description
        , category              = level
        , structureIndicator    = x.structureIndicator
        , objectType            = x.objectType
        , startupDate           = x.installedFrom
        , position              = x.position
        , superiorFloc          = parent
        , equipmentInstall      = equipmentInstall(x.structureIndicator, level)
        , status                = "UCON"
        }


    def equipmentInstall(structure: String, level: Int32): Bool = match structure {
        case "YW-GS" if level >= 5 => true
        case "YW-ES" if level >= 3 => true
        case _ => false
    }

}
