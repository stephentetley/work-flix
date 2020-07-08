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

use FactIO/FlatFile.RowEvaluator;

use AssetLib/S4/FileIO/ZTable/Relations.{Eqobjl, Flocdes, Floobjl, Manuf, Obj};
use AssetLib/S4/FileIO/ZTable/FactParser.{importRows};

namespace AssetLib/S4/FileIO/ZTable/BuiltinLoaders {

    def evalEqobjl[r](): RowEvaluator[#{ Eqobjl | r }] = 
        use FactIO/FlatFile/RowEvaluator.{flatMap, return, getString};
        let* supertype  = getString(0);
        let* subtype    = getString(1);
        let* category   = getString(1);
        return( Eqobjl(supertype, subtype, category). )

    pub def loadEqobjl[r](path: String): Result[#{ Eqobjl | r }, System.Error] & Impure =        
        importRows(evalEqobjl(), path)  


    def evalFlocdes[r](): RowEvaluator[#{ Flocdes | r }] = 
        use FactIO/FlatFile/RowEvaluator.{flatMap, return, getString};
        let* objtype    = getString(0);
        let* desc       = getString(1);
        return( Flocdes(objtype, desc). )

    pub def loadFlocdes[r](path: String): Result[#{ Flocdes | r }, System.Error] & Impure =
        importRows(evalFlocdes(), path)           


    def evalFloobjl[r](): RowEvaluator[#{ Floobjl | r }] = 
        use FactIO/FlatFile/RowEvaluator.{flatMap, return, getString, liftOperation, evalContains};
        let* structure  = getString(0);
        let* supertype  = getString(1);
        let* subtype    = getString(2);
        return( Floobjl(structure, supertype, subtype). )

    pub def loadFloobjl[r](path: String): Result[#{ Floobjl | r }, System.Error] & Impure =
        importRows(evalFloobjl(), path)  


    def evalManuf[r](): RowEvaluator[#{ Manuf | r }] = 
        use FactIO/FlatFile/RowEvaluator.{flatMap, return, getString};
        let* manuf      = getString(0);
        let* model      = getString(1);
        return( Manuf(manuf, model). )


    pub def loadManuf[r](path: String): Result[#{ Manuf | r }, System.Error] & Impure =
        importRows(evalManuf(), path)   

    def evalObj[r](): RowEvaluator[#{ Obj | r }] = 
        use FactIO/FlatFile/RowEvaluator.{flatMap, return, getString};
        let* objtype    = getString(0);
        let* manuf      = getString(1);       
        return( Obj(objtype, manuf). )

    pub def loadObj[r](path: String): Result[#{ Obj | r }, System.Error] & Impure =
        importRows(evalObj(), path)  


    type alias DbPaths = { pathOfEqobjl: String
                        , pathOfFlocdes: String
                        , pathOfFloobjl: String
                        , pathOfManuf: String
                        , pathOfObj: String
                        }

    pub def loadDb[r](paths: DbPaths): Result[#{ Eqobjl, Flocdes, Floobjl, Manuf, Obj | r }, System.Error] & Impure =
        use Result.flatMap;
        let* r1 = loadEqobjl(paths.pathOfEqobjl);
        let* r2 = loadFlocdes(paths.pathOfFlocdes);        
        let* r3 = loadFloobjl(paths.pathOfFloobjl);        
        let* r4 = loadManuf(paths.pathOfManuf);
        let* r5 = loadObj(paths.pathOfObj);
        Ok(solve r1 <+> r2 <+> r3 <+> r4 <+> r5)

}