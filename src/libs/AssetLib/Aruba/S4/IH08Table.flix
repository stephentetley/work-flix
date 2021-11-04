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

namespace AssetLib/Aruba/S4/IH08Table {
    
    use SheetIO/Reader.{XlsxSource};
    use SheetIO.NamedRowEvaluator;

    use AssetLib/Aruba/Base.{EquiType};

    /// TODO - read Base relations (alternative input source to Structure List)


    type alias IH08Row = 
        { equiId :: String
        , objectType :: String
        }

    pub def readIH08Relations(src: XlsxSource): Result[#{EquiType | r}, String] & Impure =         
        use Result.{flatMap};
        let* rows = SheetIO/Reader.readAllNamedRows(src, evalIH08Row());
        buildIH08Relations(rows)

    def evalIH08Row(): NamedRowEvaluator[IH08Row] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getLocalDateNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> 
            { equiId            = x1
            , objectType        = x2
            })
            <&> getTrimmedContentNamed("Equipment")
            <*> getTrimmedContentNamed("Object Type")
            

    def buildIH08Relations(rows: List[IH08Row]): Result[#{EquiType | r}, String] = 
        use Result.{flatMap};
        let equitypes        = getEquiTypes(rows);
        Ok(equitypes)


    def getEquiTypes(rows: List[IH08Row]): #{EquiType |r}  = 
        RelLib/Relation.foldMap(x1 -> #{ EquiType(x1.equiId, x1.objectType). }, rows)

}
