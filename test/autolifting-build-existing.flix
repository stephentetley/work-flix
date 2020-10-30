use AssetLib/S4/FileIO/ZTable/ExportDb.{ZTableSourcePaths};
use AutoLifting/TypeMapping.TypeAnswer;
use AutoLifting/Datatypes.EquiWorkItem;


def main(): Unit & Impure = 
    match mainResult() {
        case Ok() => Console.printLine("Done.")
        case Err(msg) => Console.printLine("Error: " + System/Error.toString(msg))
    }

def ztableSourcePaths(): ZTableSourcePaths = 
    { eqobjlPath    = System/FilePath.new("G:/work/assets/facts/ztables/ztable_eqobjl.txt")
    , flocdesPath   = System/FilePath.new("G:/work/assets/facts/ztables/ztable_flocdes.txt")
    , floobjlPath   = System/FilePath.new("G:/work/assets/facts/ztables/ztable_floobjl.txt")
    , manufPath     = System/FilePath.new("G:/work/assets/facts/ztables/ztable_manuf.txt")
    , objPath       = System/FilePath.new("G:/work/assets/facts/ztables/ztable_obj.txt")
    }

def classFacts(): System.FilePath = System/FilePath.new("G:/work/assets/facts/equi-class-export.txt")

def mainResult(): Result[Unit, System.Error] & Impure = 
    use Result.{flatMap};
    use AutoLifting/Common/ReportMonad.{runReportMonad};    
    use AutoLifting/ExistingObject/Build.{setupFacts, build};
    let source = 
        { equiFile          = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_equi_file_download.txt")
        , classFile         = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_equiclass_file_download.txt")
        , charFile          = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_equichar_file_download.txt")
        , mltextFile        = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_eqmltext_file_download.txt")
        , dbtempFile        = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_temp.sqlite")
        };
    let* _  = runReportMonad(setupFacts(classFacts(), ztableSourcePaths(), source.dbtempFile));
    let* _  = runReportMonad(build(source));
    Ok()

