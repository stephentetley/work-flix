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


namespace AssetLib/S4/Hierarchy/HierarchyLoader {

    use System.Error.{Generic};

    use AssetLib/S4/FileIO/DownloadFile/Evaluate.{importRows};
    use AssetLib/S4/FileIO/DownloadFile.RowEvaluator;
    use AssetLib/S4/Hierarchy/Relations.{Node};

    pub def loadEqui[r](path: System.FilePath): Result[#{ Node | r }, System.Error] & Impure =        
        importRows(equiRowParser(), path)   

    def equiRowParser[r](): RowEvaluator[#{ Node | r }] = 
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{flatMap, return, getStringNamed};
        let* id         = getStringNamed("EQUI");
        let* desc       = getStringNamed("TXTMI");
        let* parent1    = getStringNamed("HEQU_EEQZ");
        let* parent2    = getStringNamed("TPLN_EILO");
        let parent      = if (String.isEmpty(parent1)) parent2 else parent1;
        return( Node(id, desc, parent). )


    pub def loadFloc[r](path: System.FilePath): Result[#{ Node | r }, System.Error] & Impure =
        importRows(flocRowParser(), path)  
    
    def flocRowParser[r](): RowEvaluator[#{ Node | r }] = 
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{flatMap, return, getStringNamed};
        let* id1        = getStringNamed("FUNCLOC");
        let* id2        = getStringNamed("FLOC_REF");
        let id          = if (String.isMatch("\$\d+", id1)) id2 else id1;
        let* desc       = getStringNamed("TXTMI");        
        let* parent     = getStringNamed("TPLMA");        
        return( Node(id, desc, parent). )

        

}