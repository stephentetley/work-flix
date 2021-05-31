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


namespace AssetLib/GenS4/GenFlocs {

    
    use AssetLib/GenS4/XlsxSource.{XlsxSource};
    use AssetLib/GenS4/WorkListRelations.{FlocWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{FunctionalLocation, FlocCharacteristic};

    type alias GenFlocsArguments = 
        { uxlTemplate: System.FilePath
        , flocWorkList: XlsxSource
        , changeRequestName: String
        , outpath: System.FilePath
        }


    pub def genFlocs(args: GenFlocsArguments): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* workitems      = AssetLib/GenS4/WorkListRelations.readFlocWorkList(args.flocWorkList.sheet, args.flocWorkList.file);
        let flocs           = AssetLib/Gens4/FlocGen/Rules.genFlocs(workitems);
        /// query workitems select (x1, x2, x3) from FlocWorkItem(x1, x2, x3, _, _, _, _, _, _, _) |> Array.foreach(println);
        query flocs select (x1, x2, x3, x4, x5) from FunctionalLocation(x1, x2, x3, x4, x5, _, _) |> Array.foreach(println);
        /// (project EquiLongText answers) |> unsafeToString |> println;
        /// let* _          = AssetLib/GenS4/EmitUxl.outputUxl(args.changeRequestName, answers, args.uxlTemplate, args.outpath);
        Ok()




}
