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

    use FlixSandbox/System.FilePath;

    use SheetIO.Sheet;
    use SheetIO.SheetReader;
    use SheetIO.RowEvaluator;

    use AssetLib/FileIO/PDT/Datatypes.{FieldValue, PDTValueRow, ADTHeaderRow, ADTParamRow};

    pub def readFieldValuesAll(srcs: List[FilePath]): Result[#{FieldValue | r}, String] & Impure = 
        Result.traverse(readFieldValues, srcs)
            |> Result.map(RelLib/Relation.combineAll)

    pub def readFieldValues(src: FilePath): Result[#{FieldValue | r}, String] & Impure = 
        use SheetIO/SheetReader.{flatMap, point};
        let body = () -> { 
            let fileName    = getFileName(src);
            let* valueRows  = readDataSheet(fileName);
            let relns       = AssetLib/FileIO/PDT/CollateRows.collateValueRows(valueRows);
            point(relns)
        };
        SheetIO/SheetReader.runXlsx(body(), src)

    /// Defaults to input if supplied a folder
    def getFileName(src: FilePath): String = 
        src 
            |> FlixSandbox/System/FilePath.getFileName 
            |> Option.getWithDefault(src) 
            |> ToString.toString

    pub def readDataSheet(fileName: String): SheetReader[List[PDTValueRow]] = 
        use SheetIO/SheetReader.{flatMap, getSheetNames, getSheetNamed, liftOption};
        let* xs     = getSheetNames();
        let* name   = liftOption(List.find(String.startsWith(prefix ="PDT_"), xs), "Could not find PDT datasheet");
        let* sheet1 = getSheetNamed(name);
        SheetIO/SheetReader.someRows(SheetIO/RowEvaluator.optional(evalPDTRow(fileName)), sheet1)
        

    def evalPDTRow(fileName: String): RowEvaluator[PDTValueRow] = 
        use SheetIO/RowEvaluator.{flatMap, point, getRowContentsIsoLocalDateTime, getRowNum, getSheetName, liftAction, throwError};
        let* arr    = getRowContentsIsoLocalDateTime();
        let sz      = Array.length(arr);
        if (sz < 2)
            throwError("evalPDTRow - row is missing content")
        else {
            let* ix             = getRowNum();
            let* pdtClassName   = getSheetName();
            let* name           = liftAction(_ -> arr[0]);
            let* vs             = liftAction(_ -> Array.toList(arr) |> List.drop(1) |> List.map(String.trim));
            point({fileName = fileName, pdtClassName = pdtClassName, rowNumber = ix, rowName = normalize(name), cellValues = vs})
        }


    pub def readADTHeaderRowsAll(srcs: List[FilePath]): Result[List[ADTHeaderRow], String] & Impure = 
        Result.traverse(readADTHeaderRows, srcs)
            |> Result.map(List.flatten)

    def readADTHeaderRows(src: FilePath): Result[List[ADTHeaderRow], String] & Impure = 
        let fileName    = getFileName(src);
        SheetIO/SheetReader.runXlsx(readADTSheetHeaders(fileName), src)

    def readADTSheetHeaders(fileName: String): SheetReader[List[ADTHeaderRow]] = 
        use SheetIO/SheetReader.{flatMap, getSheetNames, getSheetNamed, liftOption};
        let* xs     = getSheetNames();
        let* name   = liftOption(List.find(s -> s == "PDS_ADT", xs), "Could not find PDS_ADT sheet");
        let* sheet1 = getSheetNamed(name);
        SheetIO/SheetReader.someRows(SheetIO/RowEvaluator.optional(evalADTHeaderRow(fileName)), sheet1)
        

    def evalADTHeaderRow(fileName: String): RowEvaluator[ADTHeaderRow] = 
        use SheetIO/RowEvaluator.{flatMap, point, throwError, getNonEmptyContentAt, getContentAt, getRowNum};
        let* x1     = getRowNum();
        let* x2     = getNonEmptyContentAt(0);
        let* x3     = getNonEmptyContentAt(1);
        let* x4     = getContentAt(2);
        if (not String.isEmpty(x4))
            throwError("evalADTMetaData - not a header row")
        else {
            point({fileName = fileName, rowNumber = x1, metaName = x2, metaValue = x3})
        }

    pub def readADTParamDataAll(srcs: List[FilePath]): Result[List[ADTParamRow], String] & Impure = 
        Result.traverse(readADTParamData, srcs)
            |> Result.map(List.flatten)

    def readADTParamData(src: FilePath): Result[List[ADTParamRow], String] & Impure = 
        let fileName    = getFileName(src);
        SheetIO/SheetReader.runXlsx(readADTSheetParams(fileName), src)

    pub def readADTSheetParams(fileName: String): SheetReader[List[ADTParamRow]] = 
        use SheetIO/SheetReader.{flatMap, getSheetNames, getSheetNamed, liftOption};
        let* xs     = getSheetNames();
        let* name   = liftOption(List.find(s -> s == "PDS_ADT", xs), "Could not find PDS_ADT sheet");
        let* sheet1 = getSheetNamed(name);
        SheetIO/SheetReader.someRows(SheetIO/RowEvaluator.optional(evalADTParamRow(fileName)), sheet1)
        

    def evalADTParamRow(fileName: String): RowEvaluator[ADTParamRow] = 
        use SheetIO/RowEvaluator.{flatMap, point, throwError, getRowNum, getNonEmptyContentAt, getInt32At, getTrimmedContentAt};
        ((x1, x2, x3, x4, x5, x6) -> 
            {fileName = fileName, rowNumber = x1, category = x2, paramName = normalize(x3), 
                paramIndex = x4, paramUnits = if (String.isEmpty(x5) and x1 > 10) "**Missing_Units**" else x5, notes = x6})
            <$> getRowNum()
            <*> getNonEmptyContentAt(0)
            <*> getNonEmptyContentAt(1)
            <*> getInt32At(2)
            <*> getTrimmedContentAt(3)         /// Units - ideally should be filled in
            <*> getTrimmedContentAt(4)

    def normalize(s: String): String = 
        use Text/Regex/Pattern.Flag.{Multiline};
        let flags = Multiline :: Nil;
        let patt = Text/Regex/Pattern.compileWithFlags("\\R", flags) |> Result.getWithDefault(Text/Regex/Pattern.unmatchable());
        s 
            |> String.trim
            |> Text/Regex.replace(from = patt, to = " ")

}
