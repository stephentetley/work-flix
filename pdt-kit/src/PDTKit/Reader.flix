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

namespace PDTKit/Reader {

    use Functor.{<$>};
    use Applicative.{<*>};
 
    use MonadLib/MonadOr.{optional};

    use Basis/System.FilePath;

    use SheetIO.WorkbookReader;
    use SheetIO.RowEvaluator;

    use PDTKit/Datatypes.{LeadSheetRow};

    
    pub def readPDT(path: FilePath): Result[List[LeadSheetRow], String] \ IO = 
        use SheetIO/WorkbookReader.{runXlsx};
        runXlsx(readLeadSheet(), path)

    pub def readLeadSheet(): WorkbookReader[r, List[LeadSheetRow]] \ Read(r) = 
        use SheetIO/WorkbookReader.{flatMap, getSheetNamed, withSheetReader};
        let* sheet1 = getSheetNamed("Asset Data Lead Sheet");
        withSheetReader(SheetIO/SheetReader.someRows(evalADTParamRow()), sheet1)
        

        
    def evalADTParamRow(): RowEvaluator[r, LeadSheetRow] \ Read(r) = 
        use SheetIO/RowEvaluator.{getRowNum, getNonEmptyContentAt,  getTrimmedContentAt};
        ((x1, x2, x3, x4) -> 
            {rowNumber = x1, titles = x2, description = x3, code = x4})
            <$> getRowNum()
            <*> getNonEmptyContentAt(0)
            <*> getNonEmptyContentAt(1)
            <*> getTrimmedContentAt(2)


}
