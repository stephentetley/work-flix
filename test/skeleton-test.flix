use BasicDb.DbMonad;

def main(_ars: Array[String]): Int32 & Impure = 
    Console.printLine("Running...");
    match main1() { 
        case Ok() => {Console.printLine("Okay"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }

type alias SourcePaths = 
    { ztableFlocdes: System.FilePath
    , uxlTemplate: System.FilePath
    , sourceXlsx: System.FilePath
    , outpath: System.FilePath
    }


def main1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let srcpaths = 
        { ztableFlocdes     = System/FilePath.new("G:/work/assets/facts/ztables/ztable_flocdes.txt")
        , uxlTemplate       = System/FilePath.new("G:/work/assets/skeleton/MMOP uXL.xlsx")
        , sourceXlsx        = System/FilePath.new("G:/work/assets/skeleton/skeleton1.xlsx")
        , outpath           = System/FilePath.new("G:/work/assets/skeleton/skeleton1_uxl.xlsx")
        };
    let dbpath  = System/FilePath.new("G:/work/assets/skeleton/skeleton_db.sqlite");
    let* _      = BasicDb/DbMonad.runSQLite(setupDb(srcpaths), dbpath);  
    let* _      = BasicDb/DbMonad.runSQLite(genItems(srcpaths), dbpath);
    Ok()

def genItems(paths: SourcePaths): DbMonad[Unit] =  
    use BasicDb/DbMonad.{flatMap, return, mapM, mapX, liftAction, liftActionResult};
    let* flocs = liftActionResult(_ -> Skeleton/XlsxReader.readFlocHierarchy(paths.sourceXlsx));
    let* _      = Skeleton/GenS4Lite.outputUxl("Sample upload file", flocs, paths.uxlTemplate, paths.outpath);
    return()

def setupDb(paths: SourcePaths): DbMonad[Unit] = 
    use BasicDb/DbMonad.{flatMap, return};
    let* _ = AssetLib/S4/FileIO/ZTable/ExportDb.storeFlocdes("ztable_flocdes", paths.ztableFlocdes);
    let* _ = Skeleton/SetupDb/StoreAibFacts.storeAibInputRows(paths.sourceXlsx);
    let* _ = Skeleton/SetupDb/StoreAibFacts.storeFlocMappingRows(paths.sourceXlsx);
    /// temp...
    let* parent = Skeleton/DbQueries.getParentReference("BROADWAY/(D450) FMP/MONITORING/200MM FLOW METER/EQUIPMENT: MAGNETIC FLOW INSTRUMENT");
    let* _ = BasicDb/DbMonad.liftAction(_ -> Console.printLine("Parent is: ${parent}"));
    return()


