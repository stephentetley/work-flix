use Data.Check.{Pass, Fail};

use BasicDb.DbMonad;
use BasicDb.RowEvaluator;
use BasicDb.PreparedStatementSetter;

use BasicDb/DbMonad.{runSQLite, liftAction, liftActionResult, 
        createStatement, prepareStatement, executeQuery, psExecuteQuery, allRowsX, rsClose, mapX, mapWithIndexM};

use AssetLib/S4/FileIO/UxlCsv/Datatypes.{EqClassification};

use UploadCheck/Base/RowCheck.{RowCheck, RowFail};
use UploadCheck/SqlCheckers/CharInClassCheck.{equiCharInClassCheck, charInClass};
use UploadCheck/SqlCheckers/IntRangeCheck.{equiIntRangeCheck};
use UploadCheck/SqlCheckers/SelectionValueCheck.{equiSelectionValueCheck};


def checkEquiRow(row: EqClassification, ix: Int32): DbMonad[RowCheck] = 
    use BasicDb/DbMonad.{flatMap, return};
    let* a1     = charInClass(row.characteristicName, row.className, ix);
    return(a1)

def checkEquis(): DbMonad[List[RowCheck]] = 
    use BasicDb/DbMonad.{flatMap, return};
    let uxlSrc      = System/FilePath.new("G:/work/assets/uxl/eq_characteristics.csv");
    let* rows       = liftActionResult(_ -> AssetLib/S4/FileIO/UxlCsv/CsvReader.loadEqClassifications(uxlSrc));
    let* _          = liftAction(_ -> Console.printLine("Running..."));
    let* xs         = mapWithIndexM(checkEquiRow, rows);
    return(xs)

def check1(row: EqClassification): DbMonad[Unit] = 
    use BasicDb/DbMonad.{flatMap, return};
    let* a1     = equiCharInClassCheck(row.characteristicName, row.className);
    let* _      = liftAction(_ -> if (a1) Console.print("ok") else Console.print("check failed"));
    let* a2     = equiIntRangeCheck(row.characteristicName, row.charValue);
    let* _      = liftAction(_ -> if (a2) Console.print(", ok") else Console.print(", check failed"));
    let* a3     = equiSelectionValueCheck(row.characteristicName, row.charValue);
    let* _      = liftAction(_ -> if (a3) Console.printLine(", ok") else Console.printLine(", check failed"));
    return()

def checkEqui(): DbMonad[Unit] = 
    use BasicDb/DbMonad.{flatMap, return};
    let uxlSrc      = System/FilePath.new("G:/work/assets/uxl/eq_characteristics.csv");
    let* rows       = liftActionResult(_ -> AssetLib/S4/FileIO/UxlCsv/CsvReader.loadEqClassifications(uxlSrc));
    let* _          = liftAction(_ -> Console.printLine("Running..."));
    let* _          = mapX(check1, rows);
    return()
    

def printCheck(row: RowCheck): Unit & Impure = 
    let print1 = (rc : RowFail) -> Console.printLine("Row " + Int32.toString(rc.rowIndex) + ": " + rc.failMessage);
    match row {
        case Pass => () as & Impure
        case Fail(xs) => Nel.foreach(print1, xs)
    }

def main(): Unit & Impure = 
    match runSQLite(checkEqui(), System/FilePath.new("G:/work/assets/facts/classfile_characteristics.sqlite")) {
        case Err(e) => Console.printLine(System/Error.toString(e))
        case Ok() => Console.printLine("Finished...")
    };
    match runSQLite(checkEquis(), System/FilePath.new("G:/work/assets/facts/classfile_characteristics.sqlite")) {
        case Err(e) => Console.printLine(System/Error.toString(e))
        case Ok(xs) => List.foreach(printCheck, xs)
    }

    
