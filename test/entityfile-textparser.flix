use System.Error.{Generic};

use Data/RowReader.RowWithHeadersEvaluator;
use FactIO.SQLiteRowWriter;

use AssetLib/S4/FileIO/EntityFile/Datatypes.{EntityFile};
use AssetLib/S4/FileIO/EntityFile/Parser.{parseFile};
use AssetLib/S4/FileIO/EntityFile/Evaluate.{toEntityData, toEntityData1};
use AssetLib/S4/FileIO/EntityFile/ExportCsv.{exportCsv, writeDataRow};
use AssetLib/S4/FileIO/EntityFile/ExportDb.{ExportParams, exportDb};


def main(): Result[Unit, System.Error] & Impure = 
    use Result.{flatMap};
    let* _ = csv01();
    let* _ = sqlite01();
    Ok()

def csv01(): Result[Unit, System.Error] & Impure = 
    use Result.{flatMap};
    let src     = System/FilePath.new("G:/work/Projects/assets/capital_schemes/eastn/eastn_floc_download.txt");
    let dest    = System/FilePath.new("G:/work/Projects/assets/capital_schemes/eastn/eastn_floc_download_export.csv");
    let* ast    = parseFile(src) |> Result.flatMap(toEntityData1);
    let* _      = exportCsv(writeDataRow, ast, dest);
    Ok()

type alias FlocRow  = {funcloc: String, structureIndicator: String}

def sqlite01(): Result[Unit, System.Error] & Impure = 
    use Result.{flatMap};
    let src     = System/FilePath.new("G:/work/Projects/assets/capital_schemes/eastn/eastn_floc_download.txt");
    let dest    = System/FilePath.new("G:/work/Projects/assets/capital_schemes/eastn/eastn_entities.sqlite");
    let* ast    = parseFile(src) |> Result.flatMap(toEntityData(flocHeaders(), evalFlocRow()));
    let* _      = exportDb(exportParams(), ast, dest);
    Ok()

def evalFlocRow(): RowWithHeadersEvaluator[FlocRow] = 
    use Data/RowReader/RowWithHeadersEvaluator.{flatMap, return, getString};
    let* floc       = getString("FUNCLOC");
    let* si         = getString("TPLKZ_FLC");
    return({funcloc = floc, structureIndicator = si})


def flocHeaders(): Array[String] & Impure = 
    [ "funcloc", "structure_indicator" ]

/// A RowWriter for FlocRow
def flocRowWriter(x: FlocRow): SQLiteRowWriter[Unit] = 
    use FactIO/SQLiteRowWriter.{flatMap, return, putString!};
    let* _ = putString!(0,  x.funcloc);
    let* _ = putString!(1,  x.structureIndicator);
    return()

def exportParams(): ExportParams[FlocRow] = 
        { tableName = "floc_entity"
        , createTableSql = sqlCreateTableFlocEntity()
        , insertSql = "INSERT INTO floc_entity(funcloc, structure_indicator) VALUES(?,?)"
        , writeRow = flocRowWriter
        }


def sqlCreateTableFlocEntity(): String =
    String.unwords(
        "CREATE TABLE IF NOT EXISTS floc_entity ("
            :: "funcloc                 TEXT    NOT NULL PRIMARY KEY,"
            :: "structure_indicator     TEXT    NOT NULL"
            :: ")"
            :: Nil
    )



