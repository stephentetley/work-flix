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



namespace UploadCheck/Main {

    use Data.Check.{Pass, Fail};

    use BasicDb.DbMonad;
    use BasicDb/DbMonad.{runSQLite, liftAction, liftActionResult, mapWithIndexM};

    use AssetLib/S4/FileIO/UxlFile/Datatypes.{FlClassification, EqClassification};

    use UploadCheck/Base/RowCheck.{RowChecker, RowCheck, RowFail, execRowChecker};
    use UploadCheck/SqlCheckers/CharInClassCheck.{equiCharInClass};
    use UploadCheck/SqlCheckers/IntRangeCheck.{equiIntRange};
    use UploadCheck/SqlCheckers/SelectionValueCheck.{equiSelectionValue};
    use UploadCheck/SqlCheckers/TypeCheck.{flocTypeCheck, equiTypeCheck};

    pub def runMain(uxlPath: System.FilePath): Unit & Impure = 
        match runSQLite(checkEquis(uxlPath), System/FilePath.new("G:/work/assets/facts/classfile_characteristics2.sqlite")) {
            case Err(e) => Console.printLine(System/Error.toString(e))
            case Ok(xs) => List.foreach(printCheck, xs)
        };
        match runSQLite(checkFlocs(uxlPath), System/FilePath.new("G:/work/assets/facts/classfile_characteristics2.sqlite")) {
            case Err(e) => Console.printLine(System/Error.toString(e))
            case Ok(xs) => List.foreach(printCheck, xs)
        }

        

    def checkFlocs(xlsxPath: System.FilePath): DbMonad[List[RowCheck]] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* rows       = liftActionResult(_ -> AssetLib/S4/FileIO/UxlFile/XlsxReader.loadFlClassification(xlsxPath));
        let* _          = liftAction(_ -> Console.printLine("Running..."));
        let* xs         = mapWithIndexM(execRowChecker(checkFlClassifications()), rows);
        return(xs)

    def checkFlClassifications(): RowChecker[FlClassification] = 
        /// use UploadCheck/Base/RowCheck.{<&&>};
        use UploadCheck/Base/RowCheck.{offsetIndex};
        offsetIndex(7, 
            flocTypeCheck())



    def checkEquis(xlsxPath: System.FilePath): DbMonad[List[RowCheck]] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* rows       = liftActionResult(_ -> AssetLib/S4/FileIO/UxlFile/XlsxReader.loadEqClassification(xlsxPath));
        let* _          = liftAction(_ -> Console.printLine("Running..."));
        let* xs         = mapWithIndexM(execRowChecker(checkEquiRow()), rows);
        return(xs)

    def checkEquiRow(): RowChecker[EqClassification] = 
        use UploadCheck/Base/RowCheck.{<&&>};
        use UploadCheck/Base/RowCheck.{offsetIndex};
        offsetIndex(7, 
            equiTypeCheck() <&&> equiIntRange() <&&> equiSelectionValue() <&&> equiCharInClass()
        )
        

    def printCheck(row: RowCheck): Unit & Impure = 
        let print1 = (rc : RowFail) -> Console.printLine("${rc.sheetName}, row:${Int32.toString(rc.rowIndex)} - ${rc.failMessage}");
        match row {
            case Pass => () as & Impure
            case Fail(xs) => Nel.foreach(print1, xs)
        }


}