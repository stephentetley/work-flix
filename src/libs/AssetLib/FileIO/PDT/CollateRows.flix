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

    pub rel IndexedValue(columnId: Int32, rowNum: Int32, name: String, value: String)

    pub rel ParamUnit(paramName: String, paramUnit: String)

    pub rel HasParamUnit(paramName: String)


    pub def collateValueRows(fileName: String, valueRows: List[PDTValueRow], typings: List[ADTParamRow]): #{FieldValue | r} = match valueRows {
        case x :: _ if x.rowName == "Asset Name" => {
            let r1 = makeAssetNames(x);
            let r2 = RelLib/Relation.foldMap(makeIndexedValues, valueRows);
            let r3 = makeParamUnits(typings);
            solve (r1 <+> r2 <+> r3 <+> valueRules(fileName)) project FieldValue 
        }
        case _                                     => #{}
    }

    def valueRules(fileName: String): #{AssetName, IndexedValue, FieldValue, ParamUnit, HasParamUnit} = #{

        /// HasParamUnit(fieldName) :- ParamUnit(fieldName, _).

        FieldValue(fileName, rowNum, colNum, assetName, fieldName, fieldValue) :- 
            AssetName(colNum, assetName),
            IndexedValue(colNum, rowNum, fieldName, fieldValue).
    
        /// FieldValue(fileName, rowNum, colNum, assetName, fieldName, fieldValue) :- 
        ///     AssetName(colNum, assetName),
        ///     IndexedValue(colNum, rowNum, fieldName, fieldValue),
        ///     not HasParamUnit(fieldName).
    }

    def makeAssetNames(nameRow: PDTValueRow): #{AssetName | r} = 
        let make1 = (s, col) -> RelLib/Relation.whenTrue(not String.isEmpty(s), #{ AssetName(col+1, s). });
        RelLib/Relation.foldMapWithIndex(make1, nameRow.cellValues)


    def makeIndexedValues(row: PDTValueRow): #{IndexedValue | r} = 
        let make1 = (s, col) -> RelLib/Relation.whenTrue(not String.isEmpty(s), #{ IndexedValue(col+1, row.rowNumber, row.rowName, s). });
        row.cellValues 
            |> List.map(String.trim) 
            |> RelLib/Relation.foldMapWithIndex(make1)

    def makeParamUnits(rows: List[ADTParamRow]): #{ParamUnit | r} = 
        let make1 = x1 -> RelLib/Relation.whenTrue(not String.isEmpty(x1.paramUnits), #{ ParamUnit(x1.paramName, x1.paramUnits). });
        RelLib/Relation.foldMap(make1, rows)

}
