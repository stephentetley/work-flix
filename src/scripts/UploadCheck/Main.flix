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

    use DataCheck.Check.{Pass, Fail};

    use BasicDb.DbMonad;
    
    use AssetLib/S4/FileIO/UxlFile/Datatypes.{FlClassification, EquipmentData, EqClassification};

    use UploadCheck/Base/RowCheck.{RowChecker, UxlRowCheck, UxlRowFail, execRowChecker};
    use UploadCheck/SqlCheckers/CharInClassCheck.{equiCharInClass};
    use UploadCheck/SqlCheckers/IntRangeCheck.{equiIntRange};
    use UploadCheck/SqlCheckers/SelectionValueCheck.{equiSelectionValue};
    use UploadCheck/SqlCheckers/TypeCheck.{flocTypeCheck, equiTypeCheck};
    use UploadCheck/FunCheckers/DescriptionLengthCheck.{equiDescriptionLength};


    /// Note - here the DbMonad is equivalent to the Datalog part of Flix. 
    /// Due to current performance problems we are writing the checkers with 
    /// a SQL database of facts rather than a Datalog one.
    type alias CheckerMonad[a] = DbMonad[a]

    pub def runMain(dbPath: System.FilePath, uxlPath: System.FilePath): Unit & Impure = 
        use BasicDb/DbMonad.{runSQLite};
        Console.printLine("Running...");
        match runSQLite(checkAll(uxlPath), dbPath) {
            case Err(e) => Console.printLine("Error: ${e}")
            case Ok(ans) => printCheck(ans)
        }

    def checkAll(uxlPath: System.FilePath): CheckerMonad[UxlRowCheck] = 
        use BasicDb/DbMonad.{flatMap, return, liftAction};
        use DataCheck/Check.{concat};
        let* _      = liftAction(_ -> Console.printLine("checkAll.001"));
        let* a1     = checkFlClassifications(uxlPath);
        let* _      = liftAction(_ -> Console.printLine("checkAll.002"));
        let* a2     = checkEquipmentData(uxlPath);
        let* _      = liftAction(_ -> Console.printLine("checkAll.003"));
        let* a3     = checkEqClassifications(uxlPath);
        let* _      = liftAction(_ -> Console.printLine("checkAll.return"));
        return(concat(a1 :: a2 :: a3 :: Nil))




    def checkFlClassifications(xlsxPath: System.FilePath): CheckerMonad[UxlRowCheck] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, mapWithIndexM};
        let* rows       = liftActionResult(_ -> AssetLib/S4/FileIO/UxlFile/XlsxReader.loadFlClassification(xlsxPath));
        let* xs         = mapWithIndexM(execRowChecker(checkFlClassificationsHelper()), rows);
        return(DataCheck/Check.concat(xs))

    def checkFlClassificationsHelper(): RowChecker[FlClassification] = 
        /// use UploadCheck/Base/RowCheck.{<&&>};
        use UploadCheck/Base/RowCheck.{offsetIndex};
        offsetIndex(7, 
            flocTypeCheck())

        
    def checkEquipmentData(xlsxPath: System.FilePath): CheckerMonad[UxlRowCheck] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, mapWithIndexM};
        let* rows       = liftActionResult(_ -> AssetLib/S4/FileIO/UxlFile/XlsxReader.loadEquipmentData(xlsxPath));
        let* xs         = mapWithIndexM(execRowChecker(checkEquipmentDataHelper()), rows);
        return(DataCheck/Check.concat(xs))

    def checkEquipmentDataHelper(): RowChecker[EquipmentData] = 
        /// use UploadCheck/Base/RowCheck.{<&&>};
        use UploadCheck/Base/RowCheck.{offsetIndex};
        offsetIndex(7, equiDescriptionLength())

    def checkEqClassifications(xlsxPath: System.FilePath): CheckerMonad[UxlRowCheck] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, mapWithIndexM};
        let* rows       = liftActionResult(_ -> AssetLib/S4/FileIO/UxlFile/XlsxReader.loadEqClassification(xlsxPath));
        let* xs         = mapWithIndexM(execRowChecker(checkEqClassificationsHelper()), rows);
        return(DataCheck/Check.concat(xs))

    def checkEqClassificationsHelper(): RowChecker[EqClassification] = 
        use UploadCheck/Base/RowCheck.{<&&>};
        use UploadCheck/Base/RowCheck.{offsetIndex};
        offsetIndex(7, 
            /// equiTypeCheck() <&&> equiIntRange() <&&> equiSelectionValue() <&&> equiCharInClass()
            equiIntRange() <&&> equiSelectionValue() <&&> equiCharInClass()
        )
        

    def printCheck(checks: UxlRowCheck): Unit & Impure = 
        // use ToString/ToString.toString;
        // let show = (i : Int32) -> toString(i); 
        let print1 = (rc : UxlRowFail) -> { 
                let s1 = rc.sheetName;
                let i2 = rc.rowIndex; 
                Console.printLine("${s1}, row:${i2} - ${rc.failMessage}")
        };
        match checks {
            case Pass => Console.printLine("Pass")
            case Fail(xs) => Nel.foreach(print1, xs)
        }


}