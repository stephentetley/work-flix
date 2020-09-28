
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
use AutoLifting/WorkList.EquiWorkItem;

/// def main(): Unit & Impure = 
///     use AutoLifting/MappingTable.{readMappingFile};
///     use AutoLifting/TypeMapping.{getS4TypeInfo};

///     let tablePath = System/FilePath.new("G:/work/assets/lifting-equipment-reports/01.lifting_equipment_types.xlsx");
///     match readMappingFile(tablePath) {
///         case Ok(db) => {
///             let ans = getS4TypeInfo(db, "EQUIPMENT: BEAMS - LIFTING AND SPREADING", "YW12345 BEAM 1");
///             Option.foreach(x -> Console.printLine(AutoLifting/TypeMapping.showAnswer(x)), ans)
///         }
///         case Err(msg) => Console.printLine(System/Error.toString(msg))
///     }
    
def main(): Unit & Impure = 
    match main2() {
        case Ok() => Console.printLine("Done.")
        case Err(msg) => Console.printLine(System/Error.toString(msg))
    }

def main2(): Result[Unit, System.Error] & Impure = 
    use AutoLifting/MappingTable.{readMappingFile};
    use AutoLifting/TypeMapping.{getS4TypeInfo, showS4TypeInfo};
    use AutoLifting/WorkList.{getWorkList};
    use Result.flatMap;
    let tablePath   = System/FilePath.new("G:/work/assets/lifting-equipment-reports/01.lifting_equipment_types.xlsx");
    let* db         = readMappingFile(tablePath);
    let workPath    = System/FilePath.new("G:/work/assets/lifting-equipment-reports/BBMED.xlsx");
    let* xs         = getWorkList(workPath);
    let _           = List.foreach(x1 ->
                        match getS4TypeInfo(db, x1.equiName, x1.equiType) { 
                            case Some(x) => Console.printLine(x1.equiName + ": " + showS4TypeInfo(x))
                            case None => Console.printLine(x1.equiName + ": ??")
                        }
                        , xs);
    Ok()


