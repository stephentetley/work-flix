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

    use AssetLib/FileIO/PDT/Reader.PDTRow;

    pub rel AssetName(columnId: Int32, name: String)

    pub rel IndexedValue(columnId: Int32, rowNum: Int32, name: String, value: String)

    pub rel FieldValue(rowNum: Int32, assetName: String, fieldName: String, fieldValue: String)

    

    pub def collateRows(rows: List[PDTRow]): #{FieldValue | r} = match rows {
        case x :: xs if x.rowName == "Asset Name" => {
            let r1 = makeAssetNames(x);
            let r2 = RelLib/Relation.foldMap(makeIndexedValues, xs);
            solve (r1 <+> r2 <+> rules()) project FieldValue 
        }
        case _                                     => #{}
    }

    def rules(): #{AssetName, IndexedValue, FieldValue} = #{

        FieldValue(rowNum, assetName, fieldName, fieldValue) :- 
            AssetName(colId, assetName),
            IndexedValue(colId, rowNum, fieldName, fieldValue).

    }

    def makeAssetNames(nameRow: PDTRow): #{AssetName | r} = 
        let make1 = (s, ix) -> RelLib/Relation.whenTrue(not String.isEmpty(s), #{ AssetName(ix, s). });
        RelLib/Relation.foldMapWithIndex(make1, nameRow.cellValues)


    def makeIndexedValues(row: PDTRow): #{IndexedValue | r} = 
        let make1 = (s, ix) -> RelLib/Relation.whenTrue(not String.isEmpty(s), #{ IndexedValue(ix, row.rowNumber, row.rowName, s). });
        RelLib/Relation.foldMapWithIndex(make1, row.cellValues)

}
