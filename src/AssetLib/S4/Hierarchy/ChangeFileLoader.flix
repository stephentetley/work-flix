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

use System.Error.{IllegalArgumentException, Generic};
use FactIO/FlatFile.RowWithHeadersEvaluator;

use AssetLib/S4/Hierarchy/Relations.{Node};

namespace AssetLib/S4/Hierarchy/ChangeFileLoader {


    def equiEval[r](): RowWithHeadersEvaluator[#{ Node | r }] = 
        use FactIO/FlatFile/RowWithHeadersEvaluator.{flatMap, return, getString};
        let* id         = getString("EQUI");
        let* desc       = getString("TXTMI");
        let* parent1    = getString("HEQU_EEQZ");
        let* parent2    = getString("TPLN_EILO");
        let parent      = if (String.isEmpty(parent1)) parent2 else parent1;
        return( Node(id, desc, parent). )


    pub def loadEqui[r](path: String): Result[#{ Node | r }, System.Error] & Impure =
        use AssetLib/S4/FileReaders/ChangeFile/ChangeFileImporter.{importRows};
        importRows(equiEval(), path)   

    def flocEval[r](): RowWithHeadersEvaluator[#{ Node | r }] = 
        use FactIO/FlatFile/RowWithHeadersEvaluator.{flatMap, return, getString};
        let* id1        = getString("FUNCLOC");
        let* id2        = getString("FLOC_REF");
        let id          = if (String.isMatch("\$\d+", id1)) id2 else id1;
        let* desc       = getString("TXTMI");        
        let* parent     = getString("TPLMA");        
        return( Node(id, desc, parent). )

    pub def loadFloc[r](path: String): Result[#{ Node | r }, System.Error] & Impure =
        use AssetLib/S4/FileReaders/ChangeFile/ChangeFileImporter.{importRows};
        importRows(flocEval(), path)  

}