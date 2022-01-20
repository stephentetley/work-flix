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
    let* valueRows  = SheetIO/SheetReader.runXlsx(AssetLib/FileIO/PDT/Reader.readDataSheet(), src);
    let* typings    = SheetIO/SheetReader.runXlsx(AssetLib/FileIO/PDT/Reader.readADTParamData(), src);
    let relns       = AssetLib/FileIO/PDT/CollateRows.collateValueRows(valueRows, typings);
    let* _          = BasicDb/DbMonad.runSQLite(AssetLib/FileIO/PDT/SQLite.storeFieldValues("pdt_raw_values", relns), dst);
    Ok()

/*
def tempMeta(src: System.FilePath): Result[Unit, String] & Impure =  
    use Result.{flatMap};
    let* xs = SheetIO/SheetReader.runXlsx(AssetLib/FileIO/PDT/Reader.readADTMetaData(), src);
    let _   = List.map(x -> println("${x.metaName} => ${x.metaValue}"), xs);
    let* ys = SheetIO/SheetReader.runXlsx(AssetLib/FileIO/PDT/Reader.readADTParamData(), src);
    let _   = List.map(x -> println("${x.rowNumber} ${x.paramName} => ${x.paramUnits} (${x.notes})"), ys);
    Ok()
*/
