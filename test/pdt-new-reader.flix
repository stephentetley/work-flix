use SheetIO.SheetReader;
use AssetLib/FileIO/PDT/CollateRows.{FieldValue};

pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    let src = System/FilePath.new("G:/work/assets/product-data-templates/pannal/EQUI_Valves 1.xlsx");
    let dst = System/FilePath.new("G:/work/assets/product-data-templates/pannal/pannal-pdt.sqlite");
    writeDb(src, dst) |> println;
    0


def writeDb(src: System.FilePath, dst: System.FilePath): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let fileName    = System/FilePath.getFileName(src) |> Option.getWithDefault(src) |> ToString.toString;
    let* valueRows  = SheetIO/SheetReader.runXlsx(AssetLib/FileIO/PDT/Reader.readDataSheet(), src);
    let* typings    = SheetIO/SheetReader.runXlsx(AssetLib/FileIO/PDT/Reader.readADTParamData(), src);
    let relns       = AssetLib/FileIO/PDT/CollateRows.collateValueRows(fileName, valueRows, typings);
    let* _          = BasicDb/DbMonad.runSQLite(AssetLib/FileIO/PDT/SQLite.storeFieldValues("pdt_raw_values", relns), dst);
    Ok()

