use Data.Check.{Pass, Fail};

use BasicDb.DbMonad;
use BasicDb/DbMonad.{runSQLite, liftAction, liftActionResult, mapWithIndexM};

use AssetLib/S4/FileIO/UxlCsv/Datatypes.{EqClassification};

use UploadCheck/Base/RowCheck.{RowChecker, RowCheck, RowFail, execRowChecker};
use UploadCheck/SqlCheckers/CharInClassCheck.{equiCharInClass};
use UploadCheck/SqlCheckers/IntRangeCheck.{equiIntRange};
use UploadCheck/SqlCheckers/SelectionValueCheck.{equiSelectionValue};
use UploadCheck/SqlCheckers/TypeCheck.{equiTypeCheck};


def checkEquiRow(): RowChecker[EqClassification] = 
    use UploadCheck/Base/RowCheck.{<&&>};
    use UploadCheck/Base/RowCheck.{offsetIndex};
    offsetIndex(7, 
        equiTypeCheck() <&&> equiIntRange() <&&> equiSelectionValue() <&&> equiCharInClass())
    

def checkEquis(): DbMonad[List[RowCheck]] = 
    use BasicDb/DbMonad.{flatMap, return};
    let uxlSrc      = System/FilePath.new("G:/work/assets/uxl/eq_characteristics.csv");
    let* rows       = liftActionResult(_ -> AssetLib/S4/FileIO/UxlCsv/CsvReader.loadEqClassifications(uxlSrc));
    let* _          = liftAction(_ -> Console.printLine("Running..."));
    let* xs         = mapWithIndexM(execRowChecker(checkEquiRow()), rows);
    return(xs)

    

def printCheck(row: RowCheck): Unit & Impure = 
    let print1 = (rc : RowFail) -> Console.printLine("Row " + Int32.toString(rc.rowIndex) + ": " + rc.failMessage);
    match row {
        case Pass => () as & Impure
        case Fail(xs) => Nel.foreach(print1, xs)
    }



def main(): Unit & Impure = 
    match runSQLite(checkEquis(), System/FilePath.new("G:/work/assets/facts/classfile_characteristics.sqlite")) {
        case Err(e) => Console.printLine(System/Error.toString(e))
        case Ok(xs) => List.foreach(printCheck, xs)
    }
