/*
 * Copyright 2020 Stephen Tetley
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

use Data/RowReader.RowEvaluator;

use AssetLib/S4/FileIO/ZTable/Raw/Datatypes.{Eqobjl, Flocdes, Floobjl, Manuf, Obj};
use AssetLib/S4/FileIO/ZTable/Raw/Parser.{importRows};

namespace AssetLib/S4/FileIO/ZTable/Raw/BuiltinParsers {

    type alias DbPaths = { pathOfEqobjl: System.FilePath
                        , pathOfFlocdes: System.FilePath
                        , pathOfFloobjl: System.FilePath
                        , pathOfManuf: System.FilePath
                        , pathOfObj: System.FilePath
                        }


    pub def loadEqobjl(path: System.FilePath): Result[List[Eqobjl], System.Error] & Impure =        
        importRows(evalEqobjl(), path)  

    def evalEqobjl(): RowEvaluator[Eqobjl] = 
        use Data/RowReader/RowEvaluator.{flatMap, return, getString};
        let* supero     = getString(0);
        let* subo       = getString(1);
        let* cat        = getString(2);
        return({superObject = supero, subObject = subo, category = cat})


    pub def loadFlocdes(path: System.FilePath): Result[List[Flocdes], System.Error] & Impure =
        importRows(evalFlocdes(), path)           

    def evalFlocdes(): RowEvaluator[Flocdes] = 
        use Data/RowReader/RowEvaluator.{flatMap, return, getString};
        let* objtype    = getString(0);
        let* desc       = getString(1);
        return({objectType = objtype, description = desc})


    pub def loadFloobjl(path: System.FilePath): Result[List[Floobjl], System.Error] & Impure =
        importRows(evalFloobjl(), path)  

    def evalFloobjl(): RowEvaluator[Floobjl] = 
        use Data/RowReader/RowEvaluator.{flatMap, return, getString, liftOperation, evalContains};
        let* struct     = getString(0);
        let* supero     = getString(1);
        let* subo       = getString(2);
        return({structure = struct, superObject = supero, subObject = subo})

    pub def loadManuf(path: System.FilePath): Result[List[Manuf], System.Error] & Impure =
        importRows(evalManuf(), path)   

    def evalManuf(): RowEvaluator[Manuf] = 
        use Data/RowReader/RowEvaluator.{flatMap, return, getString};
        let* manuf      = getString(0);
        let* modl       = getString(1);
        return({manufacturer = manuf, model = modl})


    pub def loadObj(path: System.FilePath): Result[List[Obj], System.Error] & Impure =
        importRows(evalObj(), path)  

    def evalObj(): RowEvaluator[Obj] = 
        use Data/RowReader/RowEvaluator.{flatMap, return, getString};
        let* objectty   = getString(0);
        let* manuf      = getString(1);
        return({objectType = objectty, manufacturer = manuf})



}