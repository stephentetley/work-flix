use BasicDb.DbMonad;
use AssetLib/S4Lite/CreateNew/Datatypes.{S4Equipment};
use AssetLib/S4Lite/CreateNew/EquipmentBuilder.{TableNames};
use AutoLifting/Base.ReportMonad;
use AutoLifting/SetupDb.{DownloadFilePaths, WorklistPaths};


def main(): Unit & Impure =  
    use AutoLifting/Base/ReportMonad.{runReportMonad};
    let dbpath          = System/FilePath.new("G:/work/assets/lifting-equipment-reports/db1.sqlite");
    let worklistPaths =     
        { worklist          = System/FilePath.new("G:/work/assets/lifting-equipment-reports/KETTLEWELL STW.xlsx")
        , attributesExport  = System/FilePath.new("G:/work/assets/lifting-equipment-reports/kettle-attribs-export.xlsx")
        , memosExport       = System/FilePath.new("G:/work/assets/lifting-equipment-reports/kettle-memos-export.xlsx")
        };        
    /// let downloads = 
    ///     { equiPath          = System/FilePath.new("G:/work/assets/lifting-equipment-reports/oldwh-equi-file_download.txt")
    ///     , eqmltxtPath       = System/FilePath.new("G:/work/assets/lifting-equipment-reports/oldwh-eqmltxt-file_download.txt")
    ///     , classEquiPath     = System/FilePath.new("G:/work/assets/lifting-equipment-reports/oldwh-classequi-file_download.txt")
    ///     , valuaEquiPath     = System/FilePath.new("G:/work/assets/lifting-equipment-reports/oldwh-valuaequi-file_download.txt")
    ///     };
    Console.printLine("Running...");
    match runReportMonad(mainHelper(worklistPaths, None, false), dbpath) {
        case Ok(ans) => {let (x,y) = ans; Console.printLine("Good - see ${System/FilePath.toString(x)} ${System/FilePath.toString(y)}")}
        case Err(msg) => Console.printLine("Error: " + System/Error.toString(msg))
    }



def mainHelper(worklistPaths: WorklistPaths, downloads: Option[DownloadFilePaths], makeBaseFacts: Bool): ReportMonad[(System.FilePath, System.FilePath)] = 
    use AutoLifting/Base/ReportMonad.{flatMap, return, liftDbMonad, whenTrue, liftAction};
    let uxlTemplate     = System/FilePath.new("G:/work/assets/lifting-equipment-reports/MMOP_uXL.xlsx");
    let manualOutput    = makeOutputName(worklistPaths.worklist, "_new_kids.xlsx");
    let uxlOutput       = makeOutputName(worklistPaths.worklist, "_new_kids_uxl.xlsx");
    let* _              = whenTrue(makeBaseFacts, liftDbMonad(_ -> setupFacts()));
    let* _              = liftDbMonad(_ -> AutoLifting/SetupDb.setupSpecificTables(worklistPaths, downloads));
    let* _              = liftAction(_ -> Console.printLine("makeReport..."));
    let* _              = AutoLifting/ReportMain.makeReport("Lifting Update", uxlTemplate, manualOutput, uxlOutput);
    return((manualOutput, uxlOutput))
    

def makeOutputName(path: System.FilePath, newSuffix: String): System.FilePath = 
    let s = Option.getWithDefault(System/FilePath.getBaseName(path), "");
    let s1 = s + newSuffix;
    System/FilePath.replaceFileName(path, s1)

def setupFacts(): DbMonad[Unit] = 
    let equiClassFacts = System/FilePath.new("G:/work/assets/facts/equi-class-export.txt");
    
    let ztableSourcePaths = 
        { eqobjlPath    = System/FilePath.new("G:/work/assets/facts/ztables/ztable_eqobjl.txt")
        , flocdesPath   = System/FilePath.new("G:/work/assets/facts/ztables/ztable_flocdes.txt")
        , floobjlPath   = System/FilePath.new("G:/work/assets/facts/ztables/ztable_floobjl.txt")
        , manufPath     = System/FilePath.new("G:/work/assets/facts/ztables/ztable_manuf.txt")
        , objPath       = System/FilePath.new("G:/work/assets/facts/ztables/ztable_obj.txt")
        };

    let mappingTablePaths = 
        { siteMappingPath           = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx")
        , typeMappingPath           = System/FilePath.new("G:/work/assets/lifting-equipment-reports/01.lifting_equipment_types.xlsx")
        , workingLoadMappingPath    = System/FilePath.new("G:/work/assets/lifting-equipment-reports/02.working_load_fields.xlsx")
        };
    AutoLifting/SetupDb.setupStaticTables(equiClassFacts, ztableSourcePaths, mappingTablePaths)

    