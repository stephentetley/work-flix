use SheetIO.SheetReader;
use AssetLib/FileIO/PDT/Reader.PDTRow;


pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    let src = System/FilePath.new("G:/work/assets/product-data-templates/pannal/EQUI_DistributionBoards.xlsx");
    match SheetIO/SheetReader.runXlsx(readPDT(), src) {
        case Ok(xs) => {List.map(printRow, xs); 0}
        case Err(msg) => {println("Error: ${msg}"); 1}
    }

def readPDT(): SheetReader[List[PDTRow]] = 
    use SheetIO/SheetReader.{flatMap, point, liftAction};
    let* sheet1     = AssetLib/FileIO/PDT/Reader.getDataSheet();
    AssetLib/FileIO/PDT/Reader.readDataSheet(sheet1)


def printRow(x: PDTRow): Unit & Impure = 
    println("${x.rowNumber} ${x.rowName} [${x.cellValues}]")


