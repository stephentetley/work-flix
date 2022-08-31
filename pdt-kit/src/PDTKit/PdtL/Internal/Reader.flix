/*
 * Copyright 2022 Stephen Tetley
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

namespace PDTKit/PdtL/Internal/Reader {

    use Functor.{<$>};
    use Applicative.{<*>};
 
    use MonadLib/MonadOr.{optional};

    use Basis/System.FilePath;

    use SheetIO.WorkbookReader;
    use SheetIO.RowEvaluator;

    use PDTKit/PdtL/Datatypes.{PdtFile};
    use PDTKit/PdtL/Internal/Datatypes.{LeadSheetRow, DataDictionaryRow, DataSheetRow};

    

    pub def readPdtFile(path: FilePath): Result[PdtFile, String] \ IO = region r1 {
        use SheetIO/WorkbookReader.{runXlsx};
        let filename1 = Basis/System/FilePath.getFileName(path) |> Option.map(ToString.toString) |> Option.getWithDefault("...");
        runXlsx(readPdtFile1(r1, filename1), path)
    }

    def readPdtFile1(r1: Region[r1], name: String): WorkbookReader[r, PdtFile] \ { Read(r), Write(r1) } = 
        use SheetIO/WorkbookReader.{flatMap, point};
        let* ls = readLeadSheet();
        let* dd = readDataDictionary();
        let* ds = readDataSheet(r1);
        point(
            { fileName = name
            , leadSheet = PDTKit/PdtL/Internal/Resolver.resolveLeadSheet(ls)
            , dataDictionary = PDTKit/PdtL/Internal/Resolver.resolveDataDictionary(dd)
            , dataSheet = 
                { sheetName = ds.sheet
                , multiAttributes = PDTKit/PdtL/Internal/Resolver.resolveDataSheetRows(ds.rows)
                }
            })


    pub def readLeadSheet(): WorkbookReader[r, List[LeadSheetRow]] \ Read(r) = 
        use SheetIO/WorkbookReader.{flatMap, getSheetNamed, withSheetReader};
        let* sheet1 = getSheetNamed("Asset Data Lead Sheet");
        withSheetReader(SheetIO/SheetReader.someRows(evalLeadSheetRow()), sheet1)
        

        
    def evalLeadSheetRow(): RowEvaluator[r, LeadSheetRow] \ Read(r) = 
        use SheetIO/RowEvaluator.{getRowNum, getNonEmptyContentAt, getTrimmedContentAt};
        Applicative.product4(getRowNum(), getNonEmptyContentAt(0), getTrimmedContentAt(1), getTrimmedContentAt(2))


    pub def readDataDictionary(): WorkbookReader[r, List[DataDictionaryRow]] \ Read(r) = 
        use SheetIO/WorkbookReader.{flatMap, getSheetNamed, withSheetReader};
        let* sheet1 = getSheetNamed("PDS_ADT");
        withSheetReader(SheetIO/SheetReader.someRows(evalDataDictionaryRow()), sheet1)

    def evalDataDictionaryRow(): RowEvaluator[r, DataDictionaryRow] \ { Read(r) } = 
        use SheetIO/RowEvaluator.{getRowNum, getNonEmptyContentAt, getTrimmedContentAt};
        Applicative.product4(getRowNum(), getNonEmptyContentAt(0), getTrimmedContentAt(1), getTrimmedContentAt(3))


    pub def readDataSheet(r1: Region[r1]): WorkbookReader[r, {sheet :: String, rows :: List[DataSheetRow]}] \ { Read(r), Write(r1) } = 
        use SheetIO/WorkbookReader.{flatMap, point, throwError, getSheetNames, getSheetNamed, withSheetReader};
        let* names = getSheetNames();
        match List.find(String.startsWith(prefix = "PDT_"), names) {
            case Some(name) => {
                let* sheet1 = getSheetNamed(name);
                let* rows = withSheetReader(SheetIO/SheetReader.someRows(evalDataSheetRow(r1)), sheet1);
                point({sheet = name, rows = rows})
            }
            case None       => throwError("Cannot find values sheet.")
        }
        
    /// `getLastCellNum` not helpful...
    def evalDataSheetRow(r1: Region[r1]): RowEvaluator[r, DataSheetRow] \ { Read(r), Write(r1) } = 
        use SheetIO/RowEvaluator.{getRowNum, getNonEmptyContentAt, getLastCellNum, getRowContents};
        Applicative.product3(getRowNum(), 
            getNonEmptyContentAt(0),
            ((getValues >> List.map(String.trim)) <$> getRowContents(r1))
        )

    /// Padd to greatest length later...
    def getValues(arr: Array[String, r1]): List[String] \ Read(r1) =  
        let step = (x, acc) -> { 
            let (seen, xs) = acc;
            match (seen, not String.isEmpty(x)) {
                case (false, false) => (false, xs)
                case (false, true)  => (true, x :: xs)
                case (_, _)         => (true, x :: xs)
            }
        };
        Array.toList(arr) |> List.drop(1) |> List.foldRight(step, (false, Nil)) |> snd

}
