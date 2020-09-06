use BasicDb.DbMonad;
use BasicDb.RowEvaluator;
use BasicDb.PreparedStatementSetter;

use BasicDb/DbMonad.{runSQLite, liftAction, liftActionResult, 
        createStatement, prepareStatement, executeQuery, psExecuteQuery, allRowsX, rsClose, mapX};

use AssetLib/S4/FileIO/UxlCsv/Datatypes.{EqClassification};
use UploadCheck/SqlCheckers/CharInClassCheck.{charInClassCheck};



def check1(row: EqClassification): DbMonad[Unit] = 
    use BasicDb/DbMonad.{flatMap, return};
    let* ans    = charInClassCheck(row.characteristicName, row.className);
    let* _      = liftAction(_ -> if (ans) Console.printLine("ok") else Console.printLine("check failed"));
    return()

def test01(): DbMonad[Unit] = 
    use BasicDb/DbMonad.{flatMap, return};
    let uxlSrc      = System/FilePath.new("G:/work/assets/uxl/eq_characteristics.csv");
    let* rows       = liftActionResult(_ -> AssetLib/S4/FileIO/UxlCsv/CsvReader.loadEqClassifications(uxlSrc));
    let* _          = liftAction(_ -> Console.printLine("Running..."));
    let* _          = mapX(check1, rows);
    return()
    

def main(): Unit & Impure = 
    match runSQLite(test01(), System/FilePath.new("G:/work/assets/facts/equi_characteristics.sqlite")) {
        case Err(e) => Console.printLine(System/Error.toString(e))
        case Ok() => Console.printLine("Finished...")
    }

    