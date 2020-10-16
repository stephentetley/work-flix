
/// def main(): Unit & Impure = 
///     let path1 = System/FilePath.new("G:/work/assets/lifting-equipment-reports/BBMED.xlsx");
///     match AssetLib/Aib/FileIO/AideChangeSummary/XlsxReader.readFile(path1) { 
///         case Err(e) => Console.printLine(System/Error.toString(e))
///         case Ok(xs) => Console.printLine("Reader done 1, row count:" + Int32.toString(List.length(xs)))
///     };
///     let path2 = System/FilePath.new("G:/work/assets/lifting-equipment-reports/01.lifting_equipment_types.xlsx");
///     match AutoLifting/MappingTable.readFile(path2) { 
///         case Err(e) => Console.printLine(System/Error.toString(e))
///         case Ok(xs) => Console.printLine("Reader done 2, row count:" + Int32.toString(List.length(xs)))
///     }


use AutoLifting/TypeMapping.TypeAnswer;
use AutoLifting/Datatypes.EquiWorkItem;

/// TODO phases make less sense that expected, its easily possible to collect aib data at the start...
def main(): Unit & Impure = 
    match mainResult() {
        case Ok() => Console.printLine("Done.")
        case Err(msg) => Console.printLine("Error: " + System/Error.toString(msg))
    }


def mainResult(): Result[Unit, System.Error] & Impure = 
    use AutoLifting/ReportMonad.{runReportMonad};
    use AutoLifting/ReportMain.{generateChildNewReport};
    use Result.flatMap;
    let reportConfig = 
        { typeTablePath = System/FilePath.new("G:/work/assets/lifting-equipment-reports/01.lifting_equipment_types.xlsx")
        , siteTablePath = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx")
        , uxlTemplatePath = System/FilePath.new("G:/work/assets/lifting-equipment-reports/MMOP_uXL.xlsx")
        };
    let reportProps = 
        { workListPath      = System/FilePath.new("G:/work/assets/lifting-equipment-reports/HULL source.xlsx")
        , attribsPath       = System/FilePath.new("G:/work/assets/lifting-equipment-reports/hull_attribs_export.xlsx")
        , memosPath         = System/FilePath.new("G:/work/assets/lifting-equipment-reports/hull_memos_export.xlsx")
        , reportDescription = "Site 01 (GC) 16/10/2020 Stephen"
        , phase2OutPath     = System/FilePath.new("G:/work/assets/lifting-equipment-reports/hull_new_kids.xlsx")
        , uxlOutPath        = System/FilePath.new("G:/work/assets/lifting-equipment-reports/hull_new_kids_uxl.xlsx")
        };
    runReportMonad(generateChildNewReport(reportConfig, reportProps))

