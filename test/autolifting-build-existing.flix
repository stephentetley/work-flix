
use AutoLifting/TypeMapping.TypeAnswer;
use AutoLifting/Datatypes.EquiWorkItem;


def main(): Unit & Impure = 
    match mainResult() {
        case Ok() => Console.printLine("Done.")
        case Err(msg) => Console.printLine("Error: " + System/Error.toString(msg))
    }


def mainResult(): Result[Unit, System.Error] & Impure = 
    use AutoLifting/Common/ReportMonad.{runReportMonad};    
    use AutoLifting/ExistingObject/Build.{build};
    let source = 
        { equiFile          = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_equi_file_download.txt")
        , classFile         = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_equiclass_file_download.txt")
        , charFile          = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_equichar_file_download.txt")
        , mltextFile        = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_eqmltext_file_download.txt")
        , dbtempFile        = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_temp.sqlite")
        , classFacts        = System/FilePath.new("G:/work/assets/facts/equi-class-export.txt")
        };
    runReportMonad(build(source))

