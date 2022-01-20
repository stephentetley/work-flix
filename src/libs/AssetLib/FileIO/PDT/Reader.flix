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

namespace AssetLib/FileIO/PDT/Reader {

    use Functor.{<$>};
    use Applicative.{<*>};

    use SheetIO.Sheet;
    use SheetIO.SheetReader;
    use SheetIO.RowEvaluator;

    use AssetLib/FileIO/PDT/Base.{FieldValue, PDTValueRow, ADTMetaData, ADTParamRow};

    pub def readFieldValuesAll(srcs: List[System.FilePath]): Result[#{FieldValue | r}, String] & Impure = 
        Result.traverse(readFieldValues, srcs)
            |> Result.map(RelLib/Relation.combineAll)

    pub def readFieldValues(src: System.FilePath): Result[#{FieldValue | r}, String] & Impure = 
        use SheetIO/SheetReader.{flatMap, point};
        let fileName    = System/FilePath.getFileName(src) |> Option.getWithDefault(src) |> ToString.toString;
        let body = () -> { 
            let* valueRows  = readDataSheet();
            let* typings    = readADTParamData();
            let relns       = AssetLib/FileIO/PDT/CollateRows.collateValueRows(fileName, valueRows, typings);
            point(relns)
        };
        SheetIO/SheetReader.runXlsx(body(), src)

    pub def readDataSheet(): SheetReader[List[PDTValueRow]] = 
        use SheetIO/SheetReader.{flatMap, getSheetNames, getSheetNamed, liftOption};
        let* xs     = getSheetNames();
        let* name   = liftOption(List.find(String.startsWith(prefix ="PDT_"), xs), "Could not find PDT datasheet");
        let* sheet1 = getSheetNamed(name);
        SheetIO/SheetReader.someRows(SheetIO/RowEvaluator.optional(evalPDTRow()), sheet1)
        

    def evalPDTRow(): RowEvaluator[PDTValueRow] = 
        use SheetIO/RowEvaluator.{flatMap, point, getRowContents, getRowNum, liftAction, throwError};
        let* arr    = getRowContents();
        let sz      = Array.length(arr);
        if (sz < 2)
            throwError("evalPDTRow - row is missing content")
        else {
            let* ix     = getRowNum();
            let* name   = liftAction(_ -> arr[0]);
            let* vs     = liftAction(_ -> Array.toList(arr) |> List.drop(1));
            point({rowNumber = ix, rowName = normalize(name), cellValues = vs})
        }



    pub def readADTMetaData(): SheetReader[List[ADTMetaData]] = 
        use SheetIO/SheetReader.{flatMap, getSheetNames, getSheetNamed, liftOption};
        let* xs     = getSheetNames();
        let* name   = liftOption(List.find(s -> s == "PDS_ADT", xs), "Could not find PDS_ADT sheet");
        let* sheet1 = getSheetNamed(name);
        SheetIO/SheetReader.someRows(SheetIO/RowEvaluator.optional(evalADTMetaData()), sheet1)
        

    def evalADTMetaData(): RowEvaluator[ADTMetaData] = 
        use SheetIO/RowEvaluator.{flatMap, point, throwError, getNonEmptyContentAt, getContentAt};
        let* x1     = getNonEmptyContentAt(0);
        let* x2     = getNonEmptyContentAt(1);
        let* x3     = getContentAt(2);
        if (not String.isEmpty(x3))
            throwError("evalADTMetaData - not a header row")
        else {
            point({metaName = x1, metaValue = x2})
        }

    pub def readADTParamData(): SheetReader[List[ADTParamRow]] = 
        use SheetIO/SheetReader.{flatMap, getSheetNames, getSheetNamed, liftOption};
        let* xs     = getSheetNames();
        let* name   = liftOption(List.find(s -> s == "PDS_ADT", xs), "Could not find PDS_ADT sheet");
        let* sheet1 = getSheetNamed(name);
        SheetIO/SheetReader.someRows(SheetIO/RowEvaluator.optional(evalADTParamData()), sheet1)
        

    def evalADTParamData(): RowEvaluator[ADTParamRow] = 
        use SheetIO/RowEvaluator.{flatMap, point, throwError, getRowNum, getNonEmptyContentAt, getInt32At, getContentAt};
        ((x1, x2, x3, _, x4, x5) -> {rowNumber = x1, category = x2, paramName = normalize(x3), paramUnits = x4, notes = x5})
            <$> getRowNum()
            <*> getNonEmptyContentAt(0)
            <*> getNonEmptyContentAt(1)
            <*> getInt32At(2)
            <*> getNonEmptyContentAt(3)
            <*> getContentAt(4)

    def normalize(s: String): String = 
        use Text/Regex/Pattern.Flag.{Multiline};
        let flags = Multiline :: Nil;
        let patt = Text/Regex/Pattern.compileWithFlags("\\R", flags) |> Result.getWithDefault(Text/Regex/Pattern.unmatchable());
        s 
            |> String.trim
            |> Text/Regex.replace(from = patt, to = " ")

}
