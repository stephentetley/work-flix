use SheetIO.SheetReader;
use AssetLib/FileIO/PDT/Reader.PDTRow;
use AssetLib/FileIO/PDT/CollateRows.{FieldValue};

pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    let src = System/FilePath.new("G:/work/assets/product-data-templates/pannal/EQUI_Valves 1.xlsx");
    match SheetIO/SheetReader.runXlsx(AssetLib/FileIO/PDT/Reader.readDataSheet(), src) {
        case Ok(xs) => {
            AssetLib/FileIO/PDT/CollateRows.collateRows(xs) 
                |> db -> query db select (x1, x2, x3, x4) from FieldValue(x1, x2, x3, x4) |> Array.foreach(println); 
            0
        }
        case Err(msg) => {println("Error: ${msg}"); 1}
    }





