
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

def main(): Unit & Impure = 
    use AutoLifting/TypeMapping.{Distinguished, distinguishedMatch};
    let db = #{
        Distinguished("EQUIPMENT: BEAMS - LIFTING AND SPREADING", "BEAM", "H", "CRHT", "CRHTLB", "Fixed").
    };
    let xs = distinguishedMatch(db, "EQUIPMENT: BEAMS - LIFTING AND SPREADING", "xzy/STATUTORY/LIFTING EQUIPMENT/YW12345 RUNWAY BEAM/BEAMS - LIFTING AND SPREADING");
    List.foreach(x -> Console.printLine(AutoLifting/TypeMapping.showAnswer(x)), xs)

