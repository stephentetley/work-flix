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

namespace AssetLib/FileIO/PDT/CollateRows {


    use AssetLib/FileIO/PDT/Datatypes.{FieldValue, PDTValueRow, ADTParamRow};

    pub rel AssetName(columnId: Int32, name: String)

    pub rel IndexedValue(columnId: Int32, rowNum: Int32, fileName: String, pdtClassNAme: String, name: String, value: String)

    /// This makes rows for each "value column" and does a join so each row gets assigned the asset name.
    pub def collateValueRows(valueRows: List[PDTValueRow]): #{FieldValue | r} = match valueRows {
        case x :: _ if x.rowName == "Asset Name" => {
            let r1 = makeAssetNames(x);
            let r2 = RelLib/Relation.foldMap(makeIndexedValues, valueRows);
            solve (r1 <+> r2 <+> valueRules()) project FieldValue 
        }
        case _                                     => #{}
    }

    def valueRules(): #{AssetName, IndexedValue, FieldValue} = #{

        FieldValue(fileName, pdtClassName, rowNum, colNum, assetName, fieldName, fieldValue) :- 
            AssetName(colNum, assetName),
            IndexedValue(colNum, rowNum, fileName, pdtClassName, fieldName, fieldValue).
    
    }

    def makeAssetNames(nameRow: PDTValueRow): #{AssetName | r} = 
        let make1 = (s, col) -> RelLib/Relation.whenTrue(not String.isEmpty(s), #{ AssetName(col+1, s). });
        RelLib/Relation.foldMapWithIndex(make1, nameRow.cellValues)


    def makeIndexedValues(row: PDTValueRow): #{IndexedValue | r} = 
        let make1 = (s, col) -> 
            RelLib/Relation.whenTrue(not String.isEmpty(s), #{ IndexedValue(col+1, row.rowNumber, row.fileName, row.pdtClassName, row.rowName, s). });
        row.cellValues 
            |> List.map(String.trim) 
            |> RelLib/Relation.foldMapWithIndex(make1)

}
