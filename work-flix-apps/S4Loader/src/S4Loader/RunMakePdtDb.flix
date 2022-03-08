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
 
namespace S4Loader/RunMakePdtDb {

    use SheetIO.SheetReader;
    use AssetLib/FileIO/PDT/Base.{FieldValue};



    pub def makePdtDb(_args: Array[String]): Int32 & Impure = 
        println("Running... ${Time/LocalTime.now()}");

        let srcdir  = System/FilePath.new("G:/work/assets/capital_schemes/sca05/pdts2");
        let srcs    = System/Directory.contents(srcdir) |> Result.getWithDefault(Nil) |> List.filter(x -> System/FilePath.getExtension(x) == Some("xlsx"));    
        let dst     = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-dsear-pdt.sqlite");
        
        AssetLib/FileIO/PDT/SQLite.createPDTDatabase(srcs, dst) |> println;
        
        0

}
