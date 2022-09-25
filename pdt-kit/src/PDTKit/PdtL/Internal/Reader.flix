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

    use Basis/System.Path;

    use SheetIO.WorkbookReader;
    use SheetIO.RowEvaluator;

    use PDTKit/PdtL/Datatypes.{PdtFile};
    use PDTKit/PdtL/Internal/Datatypes.{LeadSheetRow, DataDictionaryRow, DataSheetRow};

    

    pub def readPdtFile(path: Path): Result[PdtFile, String] \ IO = region r1 {
        use SheetIO/WorkbookReader.{runXlsx};
        let filename1 = Basis/System/Path.getFileName(path) |> Option.map(ToString.toString) |> Option.getWithDefault("...");
        runXlsx(r1, readPdtFile1(filename1), path)
    }

    def readPdtFile1(name: String): WorkbookReader[r, ka, PdtFile] \ { Read(r) } = 
        use SheetIO/WorkbookReader.{flatMap, point};
        let* ls = readLeadSheet();
        let* dd = readDataDictionary();
        let* ds = readDataSheet();
        point(
            { fileName = name
            , leadSheet = PDTKit/PdtL/Internal/Resolver.resolveLeadSheet(ls)
            , dataDictionary = PDTKit/PdtL/Internal/Resolver.resolveDataDictionary(dd)
            , dataSheet = 
                { sheetName = ds.sheet
                , multiAttributes = PDTKit/PdtL/Internal/Resolver.resolveDataSheetRows(ds.rows)
                }
            })


    pub def readLeadSheet(): WorkbookReader[r, ka, List[LeadSheetRow]] \ Read(r) = 
        use SheetIO/WorkbookReader.{flatMap, getSheetNamed, withSheetReader};
        let* sheet1 = getSheetNamed("Asset Data Lead Sheet");
        withSheetReader(SheetIO/SheetReader.someRows(evalLeadSheetRow()), sheet1)
        

        
    def evalLeadSheetRow(): RowEvaluator[r, ka, LeadSheetRow] \ Read(r) = 
        use SheetIO/RowEvaluator.{getRowNum, getNonEmptyContentAt, getTrimmedContentAt};
        Applicative.product4(getRowNum(), getNonEmptyContentAt(0), getTrimmedContentAt(1), getTrimmedContentAt(2))


    pub def readDataDictionary(): WorkbookReader[r, ka, List[DataDictionaryRow]] \ Read(r) = 
        use SheetIO/WorkbookReader.{flatMap, getSheetNamed, withSheetReader};
        let* sheet1 = getSheetNamed("PDS_ADT");
        withSheetReader(SheetIO/SheetReader.someRows(evalDataDictionaryRow()), sheet1)

    def evalDataDictionaryRow(): RowEvaluator[r, ka, DataDictionaryRow] \ { Read(r) } = 
        use SheetIO/RowEvaluator.{getRowNum, getNonEmptyContentAt, getTrimmedContentAt};
        Applicative.product4(getRowNum(), getNonEmptyContentAt(0), getTrimmedContentAt(1), getTrimmedContentAt(3))


    pub def readDataSheet(): WorkbookReader[r, ka, {sheet :: String, rows :: List[DataSheetRow]}] \ { Read(r) } = 
        use SheetIO/WorkbookReader.{flatMap, point, throwError, getSheetNames, getSheetNamed, withSheetReader};
        let* names = getSheetNames();
        match List.find(String.startsWith(prefix = "PDT_"), names) {
            case Some(name) => {
                let* sheet1 = getSheetNamed(name);
                let* rows = withSheetReader(SheetIO/SheetReader.someRows(evalDataSheetRow()), sheet1);
                point({sheet = name, rows = rows})
            }
            case None       => throwError("Cannot find values sheet.")
        }
        
    /// `getLastCellNum` not helpful...
    def evalDataSheetRow(): RowEvaluator[r, ka, DataSheetRow] \ { Read(r)} = 
        use SheetIO/RowEvaluator.{getRowNum, getNonEmptyContentAt, getLastCellNum, getRowContents};
        Applicative.product3(getRowNum(), 
            getNonEmptyContentAt(0),
            ((getValues >> List.map(String.trim)) <$> getRowContents())
        )

    /// Pad to greatest length later...
    def getValues(l: List[String]): List[String]  =  
        let step = (x, acc) -> { 
            let (seen, xs) = acc;
            match (seen, not String.isEmpty(x)) {
                case (false, false) => (false, xs)
                case (false, true)  => (true, x :: xs)
                case (_, _)         => (true, x :: xs)
            }
        };
        List.drop(1, l) |> List.foldRight(step, (false, Nil)) |> snd

}
