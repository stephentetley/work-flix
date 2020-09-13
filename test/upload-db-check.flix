use BasicDb.DbMonad;
use BasicDb.RowEvaluator;
use BasicDb.PreparedStatementSetter;

use BasicDb/DbMonad.{runSQLite, liftAction, liftActionResult, 
        createStatement, prepareStatement, executeQuery, psExecuteQuery, allRowsX, rsClose, mapX};

use AssetLib/S4/FileIO/UxlCsv/Datatypes.{EqClassification};
use UploadCheck/SqlCheckers/CharInClassCheck.{equiCharInClassCheck};
use UploadCheck/SqlCheckers/IntRangeCheck.{equiIntRangeCheck};
use UploadCheck/SqlCheckers/SelectionValueCheck.{equiSelectionValueCheck};

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
    

def main(): Unit & Impure = 
    match runSQLite(checkEqui(), System/FilePath.new("G:/work/assets/facts/classfile_characteristics.sqlite")) {
        case Err(e) => Console.printLine(System/Error.toString(e))
        case Ok() => Console.printLine("Finished...")
    }

    