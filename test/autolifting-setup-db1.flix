
use AssetLib/S4/FileIO/ZTable/ExportDb.ZTableSourcePaths;
use AutoLifting/SetupDb.{MappingTablePaths, DownloadFilePaths, WorklistPaths};

/// Warning `calde-sms-lft-EQMLTXT-file_download.txt` has multiline text which breaks the parser...

def main(): Unit & Impure = 
    let worklistPaths =     
        { worklistPath  = System/FilePath.new("G:/work/assets/lifting-equipment-reports/CALDER VALE STW.xlsx")
        , attribsPath   = System/FilePath.new("G:/work/assets/lifting-equipment-reports/calde-attribs-export.xlsx")
        , memosPath     = System/FilePath.new("G:/work/assets/lifting-equipment-reports/calde-memos-export.xlsx")
        };        
    let downloads = 
        { equiPath          = System/FilePath.new("G:/work/assets/lifting-equipment-reports/calde-EQUI-file_download.txt")
        , eqmltxtPath       = System/FilePath.new("G:/work/assets/lifting-equipment-reports/calde-EQMLTXT-file_download.txt")
        , classEquiPath     = System/FilePath.new("G:/work/assets/lifting-equipment-reports/calde-CLASSEQUI-file_download.txt")
        , valuaEquiPath     = System/FilePath.new("G:/work/assets/lifting-equipment-reports/calde-VALUAEQUI-file_download.txt")
        };
    let outpath         = System/FilePath.new("G:/work/assets/lifting-equipment-reports/db1.sqlite");
    Console.printLine("Running...");
    match mainHelper(worklistPaths, Some(downloads), outpath) {
        case Ok() => Console.printLine("Done.")
        case Err(msg) => Console.printLine("Error: " + System/Error.toString(msg))
    }

def mainHelper(worklistPaths: WorklistPaths, downloads: Option[DownloadFilePaths], dboutpath: System.FilePath): Result[Unit, System.Error] & Impure = 
    use BasicDb/DbMonad.{runSQLite};
    use BasicDb/DbMonad.{flatMap, return};
    use AutoLifting/SetupDb.{setupStaticTables, setupSpecificTables};
    let action = _ -> {
        let* _ = setupStaticTables(equiClassFacts(), ztableSourcePaths(), mappingTablePaths());
        let* _ = setupSpecificTables(worklistPaths, downloads);
        return()
    };
    runSQLite(action(), dboutpath)


def equiClassFacts(): System.FilePath = System/FilePath.new("G:/work/assets/facts/equi-class-export.txt")

def ztableSourcePaths(): ZTableSourcePaths = 
    { eqobjlPath    = System/FilePath.new("G:/work/assets/facts/ztables/ztable_eqobjl.txt")
    , flocdesPath   = System/FilePath.new("G:/work/assets/facts/ztables/ztable_flocdes.txt")
    , floobjlPath   = System/FilePath.new("G:/work/assets/facts/ztables/ztable_floobjl.txt")
    , manufPath     = System/FilePath.new("G:/work/assets/facts/ztables/ztable_manuf.txt")
    , objPath       = System/FilePath.new("G:/work/assets/facts/ztables/ztable_obj.txt")
    }

def mappingTablePaths(): MappingTablePaths = 
    { siteMappingPath           = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx")
    , typeMappingPath           = System/FilePath.new("G:/work/assets/lifting-equipment-reports/01.lifting_equipment_types.xlsx")
    , workingLoadMappingPath    = System/FilePath.new("G:/work/assets/lifting-equipment-reports/02.working_load_fields.xlsx")
    }





