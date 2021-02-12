use AssetLib/S4/FileIO/IH06Tree/ExportDb.{defaultTableNames, storeIH06Trees};
use AssetLib/S4/FileIO/IH08Table/ExportDb.{storeIH08Table};
use AssetLib/Aib/FileIO/TreeExport/ExportDb.{storeTreeExport};

def main(_args: Array[String]): Int32 & Impure =
    use Result.flatMap;
    let step = () -> {
        let tableNames  = {flocNodes = "wethe_floc", equiNodes = "wethe_equi"};
        let ih06Src     = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06-all.txt");
        let ih08Src     = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-equi-ih08.xlsx");
        let aibSrc      = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wetherby-aib-export.xlsx");
        /// let piSrc       = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-aib-pandi-export.xlsx");
        let dbdest      = System/FilePath.new("G:/work/assets/capital_schemes/lee22/lee22-ih06.sqlite");
        let* _          = BasicDb/DbMonad.runSQLite(storeIH06Trees(tableNames, ih06Src, Text/Charset.utf_8(), true), dbdest);
        let* _          = BasicDb/DbMonad.runSQLite(storeIH08Table("wethe_tech_id", true, ih08Src), dbdest);
        let* _          = BasicDb/DbMonad.runSQLite(storeTreeExport("wethe_aib", aibSrc), dbdest);
        /// let* _          = BasicDb/DbMonad.runSQLite(storePIMapping("wethe_aib_pi", piSrc), dbdest);
        Ok()
    };
    match step() {
        case Ok() => {Console.printLine("Okay"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }


