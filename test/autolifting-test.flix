
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
    let factsPaths = 
        { typeTablePath = System/FilePath.new("G:/work/assets/lifting-equipment-reports/01.lifting_equipment_types.xlsx")
        , siteTablePath = System/FilePath.new("G:/work/assets/facts/AI2toS4Hana_Lvl1_2FlocMapping.xlsx")
        };
    let inputPaths = 
        { workListPath  = System/FilePath.new("G:/work/assets/lifting-equipment-reports/SCARBO source.xlsx")
        , attribsPath   = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_attribs_export.xlsx")
        , memosPath      = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_memo_export.xlsx")
        };
    let outPath     = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_new_childs.xlsx");
    runReportMonad(generateChildNewReport(factsPaths, inputPaths, outPath))

