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


namespace AssetLib/FileIO/S4/ZTable/Builtins {

    use AssetLib/FileIO/S4/ZTable/Datatypes.{Eqobjl, Flocdes, Floobjl, Manuf, Obj};
    use AssetLib/FileIO/S4/ZTable/Parser.{importRows};

    use AssetLib/FileIO/S4/ZTable.RowEvaluator;


    pub def loadEqobjl(path: System.FilePath): Result[List[Eqobjl], String] & Impure =        
        importRows(evalEqobjl(), path)  

    def evalEqobjl(): RowEvaluator[Eqobjl] = 
        use AssetLib/FileIO/S4/ZTable/RowEvaluator.{flatMap, return, getStringAt};
        let* supero     = getStringAt(0);
        let* subo       = getStringAt(1);
        let* cat        = getStringAt(2);
        return({superObject = supero, subObject = subo, category = cat})


    pub def loadFlocdes(path: System.FilePath): Result[List[Flocdes], String] & Impure =
        importRows(evalFlocdes(), path)           

    def evalFlocdes(): RowEvaluator[Flocdes] = 
        use AssetLib/FileIO/S4/ZTable/RowEvaluator.{flatMap, return, getStringAt};
        let* objtype    = getStringAt(0);
        let* desc       = getStringAt(1);
        return({objectType = objtype, description = desc})


    pub def loadFloobjl(path: System.FilePath): Result[List[Floobjl], String] & Impure =
        importRows(evalFloobjl(), path)  

    def evalFloobjl(): RowEvaluator[Floobjl] = 
        use AssetLib/FileIO/S4/ZTable/RowEvaluator.{flatMap, return, getStringAt};
        let* struct     = getStringAt(0);
        let* supero     = getStringAt(1);
        let* subo       = getStringAt(2);
        return({structure = struct, superObject = supero, subObject = subo})

    pub def loadManuf(path: System.FilePath): Result[List[Manuf], String] & Impure =
        importRows(evalManuf(), path)   

    def evalManuf(): RowEvaluator[Manuf] = 
        use AssetLib/FileIO/S4/ZTable/RowEvaluator.{flatMap, return, getStringAt};
        let* manuf      = getStringAt(0);
        let* modl       = getStringAt(1);
        return({manufacturer = manuf, model = modl})


    pub def loadObj(path: System.FilePath): Result[List[Obj], String] & Impure =
        importRows(evalObj(), path)  

    def evalObj(): RowEvaluator[Obj] = 
        use AssetLib/FileIO/S4/ZTable/RowEvaluator.{flatMap, return, getStringAt};
        let* objectty   = getStringAt(0);
        let* manuf      = getStringAt(1);
        return({objectType = objectty, manufacturer = manuf})



}