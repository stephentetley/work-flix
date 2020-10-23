use Data.Check.{Pass, Fail};

use BasicDb.DbMonad;
use BasicDb/DbMonad.{runSQLite, liftAction, liftActionResult, mapWithIndexM};

use AssetLib/S4/FileIO/UxlFile/Datatypes.{FlClassification, EqClassification};

use UploadCheck/Base/RowCheck.{RowChecker, RowCheck, RowFail, execRowChecker};
use UploadCheck/SqlCheckers/CharInClassCheck.{equiCharInClass};
use UploadCheck/SqlCheckers/IntRangeCheck.{equiIntRange};
use UploadCheck/SqlCheckers/SelectionValueCheck.{equiSelectionValue};
use UploadCheck/SqlCheckers/TypeCheck.{flocTypeCheck, equiTypeCheck};



def main(): Unit & Impure = 
    let xlsxPath = System/FilePath.new("G:/work/assets/uxl/hull_new_kids_uxl.xlsx");
    match runSQLite(checkEquis(xlsxPath), System/FilePath.new("G:/work/assets/facts/classfile_characteristics2.sqlite")) {
        case Err(e) => Console.printLine(System/Error.toString(e))
        case Ok(xs) => List.foreach(printCheck, xs)
    };
    match runSQLite(checkFlocs(xlsxPath), System/FilePath.new("G:/work/assets/facts/classfile_characteristics2.sqlite")) {
        case Err(e) => Console.printLine(System/Error.toString(e))
        case Ok(xs) => List.foreach(printCheck, xs)
    }

    

def checkFlocs(xlsxPath: System.FilePath): DbMonad[List[RowCheck]] = 
    use BasicDb/DbMonad.{flatMap, return};
    let* rows       = liftActionResult(_ -> AssetLib/S4/FileIO/UxlFile/XlsxReader.loadFlClassification(xlsxPath));
    let* _          = liftAction(_ -> Console.printLine("Running..."));
    let* xs         = mapWithIndexM(execRowChecker(checkFlocRow()), rows);
    return(xs)

def checkFlocRow(): RowChecker[FlClassification] = 
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
    let print1 = (rc : RowFail) -> Console.printLine("Row " + Int32.toString(rc.rowIndex) + ": " + rc.failMessage);
    match row {
        case Pass => () as & Impure
        case Fail(xs) => Nel.foreach(print1, xs)
    }


