use BasicDb.DbMonad;

type alias SetupPaths = 
    { siteMappingTable: System.FilePath
    , aibExport: System.FilePath
    , ih08Export: System.FilePath
    }


def main(_args: Array[String]): Int32 & Impure = 
    use BasicDb/DbMonad.{runSQLite};
    Console.printLine("Running...");
    let outpath = System/FilePath.new("G:/work/assets/ultrasonics/ultrasonics.sqlite");
    let paths = 
        { siteMappingTable = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx")
        , aibExport = System/FilePath.new("G:/work/assets/ultrasonics/ai2-ultrasonics-export.xlsx")
        , ih08Export = System/FilePath.new("G:/work/assets/ultrasonics/lstn-ih08-export.xlsx")
        };
    match runSQLite(sutupDb(paths), outpath) {
        case Ok(_) => {Console.printLine("Wrote: ${outpath}"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }
    

def sutupDb(paths: SetupPaths): DbMonad[Unit] = 
    use BasicDb/DbMonad.{flatMap, return};
    use Ultrasonics/SetupDb/IH08List.{storeIH08List};
    use Ultrasonics/SetupDb/AibList.{storeAibList};
    let* _  = AssetLib/Facts/SiteMapping.storeSiteMapping("lookup_site", paths.siteMappingTable);
    let* _  = storeAibList("aib_ultrasonics", paths.aibExport);
    let* _  = storeIH08List("s4_ultrasonics", paths.ih08Export);
    return()

