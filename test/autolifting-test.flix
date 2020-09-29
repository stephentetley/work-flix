
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

    
def main(): Unit & Impure = 
    match main2() {
        case Ok() => Console.printLine("Done.")
        case Err(msg) => Console.printLine(System/Error.toString(msg))
    }

def main2(): Result[Unit, System.Error] & Impure = 
    use AutoLifting/ReportMonad.{runReportMonad};
    use AutoLifting/ReportMain.{reportPhase1};
    use Result.flatMap;
    let typesDbPath = System/FilePath.new("G:/work/assets/lifting-equipment-reports/01.lifting_equipment_types.xlsx");
    let sitesDbPath = System/FilePath.new("G:/work/assets/facts/AI2toS4Hana_Lvl1_2FlocMapping.xlsx");
    let workPath    = System/FilePath.new("G:/work/assets/lifting-equipment-reports/BBMED.xlsx");
    runReportMonad(reportPhase1(typesDbPath, sitesDbPath, workPath))
