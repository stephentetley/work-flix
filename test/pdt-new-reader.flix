use SheetIO.SheetReader;
use AssetLib/FileIO/PDT/Base.{FieldValue};

pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    let srcdir  = System/FilePath.new("G:/work/assets/product-data-templates/pannal");
    let srcs    = System/Directory.contents(srcdir) |> Result.getWithDefault(Nil) |> List.filter(x -> System/FilePath.getExtension(x) == Some("xlsx"));
    let dst = System/FilePath.new("G:/work/assets/product-data-templates/pannal/pannal-pdt.sqlite");
    writeDb(srcs, dst) |> println;
    0


def writeDb(srcs: List[System.FilePath], dst: System.FilePath): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let* relns  = AssetLib/FileIO/PDT/Reader.readFieldValuesAll(srcs);
    let* _      = BasicDb/DbMonad.runSQLite(AssetLib/FileIO/PDT/SQLite.storeFieldValues("pdt_raw_values", relns), dst);
    Ok()

