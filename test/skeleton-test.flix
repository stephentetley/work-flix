use BasicDb.DbMonad;

def main(_ars: Array[String]): Int32 & Impure = 
    Console.printLine("Running...");
    match main1() { 
        case Ok() => {Console.printLine("Okay"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }

type alias SourcePaths = 
    { ztableFlocdes: System.FilePath
    , sourceXlsx: System.FilePath
    }


def main1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let srcpaths = 
        { ztableFlocdes = System/FilePath.new("G:/work/assets/facts/ztables/ztable_flocdes.txt")
        , sourceXlsx = System/FilePath.new("G:/work/assets/skeleton/skeleton1.xlsx")
        };
    let dbpath  = System/FilePath.new("G:/work/assets/skeleton/skeleton_db.sqlite");
    let* _      = BasicDb/DbMonad.runSQLite(setupDb(srcpaths), dbpath);
    let* xs     = Skeleton/XlsxReader.readAnnotatedAibExport(srcpaths.sourceXlsx);
    let _       = List.foreach(x -> Console.printLine("${x.reference} ${x.installedFrom}"), xs);       
    Ok()


def setupDb(paths: SourcePaths): DbMonad[Unit] = 
    use BasicDb/DbMonad.{flatMap, return, liftActionResult};
    let* _ = AssetLib/S4/FileIO/ZTable/ExportDb.storeFlocdes("ztable_flocdes", paths.ztableFlocdes);
    let* _ = Skeleton/SetupDb/StoreAibFacts.storeAibInputRows(paths.sourceXlsx);
    return()


