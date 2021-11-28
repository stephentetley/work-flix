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
    let outpath = System/FilePath.new("G:/work/assets/ultrasonics/ultrasonics.sqlite");
    let paths = 
        { siteMappingTable = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx")
        , aibExport = System/FilePath.new("G:/work/assets/ultrasonics/ai2-ultrasonics-export.xlsx")
        , ih08Export = System/FilePath.new("G:/work/assets/ultrasonics/lstn-ih08-export.xlsx")
        , classequiDownload = System/FilePath.new("G:/work/assets/ultrasonics/lstnut-file-download.txt")
        };
    match runSQLite(setupDb(paths), outpath) {
        case Ok(_) => {Console.printLine("Wrote: ${outpath}"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }
    

def setupDb(paths: SetupPaths): DbMonad[Unit] = 
    use BasicDb/DbMonad.{flatMap, point};
    let* _  = AssetLib/Facts/SiteMapping.storeSiteMapping("lookup_site", paths.siteMappingTable);
    let* _  = Ultrasonics/SetupDb/AibList.storeAibList("aib_ultrasonics", paths.aibExport);
    let* _  = Ultrasonics/SetupDb/IH08List.storeIH08List("s4_ultrasonics", paths.ih08Export);
    let* _  = AssetLib/FileIO/S4/TransferFile/Builtins.storeClassEquiFile("s4_classequi", true, paths.classequiDownload);
    point()

