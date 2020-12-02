use AssetLib/S4/FileIO/IH06Tree/ExportDb.{defaultTableNames, storeIH06Trees};
use AssetLib/Aib/FileIO/TreeExport/ExportDb.{storeTreeExport};


def main(): Result[Unit, System.Error] & Impure =
    use Result.flatMap;
    let tableNames  = {flocNodes = "wethe_floc", equiNodes = "wethe_equi"};
    let ih06Src     = System/FilePath.new("G:/work/assets/capital_schemes/lee22/wethe-ih06-all.txt");
    let aibSrc      = System/FilePath.new("G:/work/assets/capital_schemes/lee22/wetherby-aib-export.xlsx");
    let dbdest      = System/FilePath.new("G:/work/assets/capital_schemes/lee22/lee22-ih06.sqlite");
    let* _          = BasicDb/DbMonad.runSQLite(storeIH06Trees(tableNames, ih06Src, Text/Charset.utf_8(), true), dbdest);    
    let* _          = BasicDb/DbMonad.runSQLite(storeTreeExport("wethe_aib", aibSrc), dbdest);
    Ok()


