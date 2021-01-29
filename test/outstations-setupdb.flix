use BasicDb.DbMonad;

type alias SetupPaths = 
    { siteMappingTable: System.FilePath
    , aibExport: System.FilePath
    , ih08Export: System.FilePath
    , classequiDownload: System.FilePath
    }


def main(_args: Array[String]): Int32 & Impure = 
    use BasicDb/DbMonad.{runSQLite};
    Console.printLine("Running...");
    let outpath = System/FilePath.new("G:/work/assets/outstations/outstations.sqlite");
    let paths = 
        { siteMappingTable = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx")
        , aibExport = System/FilePath.new("G:/work/assets/outstations/outstations-aib-export.xlsx")
        , ih08Export = System/FilePath.new("G:/work/assets/outstations/ih08-outstations.xlsx")
        , classequiDownload = System/FilePath.new("G:/work/assets/outstations/netwtl_file_download.txt")
        };
    match runSQLite(setupDb(paths), outpath) {
        case Ok(_) => {Console.printLine("Wrote: ${outpath}"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }
    

def setupDb(paths: SetupPaths): DbMonad[Unit] = 
    use BasicDb/DbMonad.{flatMap, return};
    let* _  = AssetLib/Facts/SiteMapping.storeSiteMapping("lookup_site", paths.siteMappingTable);
    let* _  = EquiCompare/SetupDb/AibList.storeAibList("aib_equipment", paths.aibExport);
    let* _  = EquiCompare/SetupDb/IH08List.storeIH08List("s4_equipment", paths.ih08Export);
    let* _  = AssetLib/S4/FileIO/TransferFile/Builtins.storeClassEquiFile("s4_classequi", true, paths.classequiDownload);
    return()

