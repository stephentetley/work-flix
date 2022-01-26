use SheetIO.SheetReader;
use AssetLib/FileIO/PDT/Base.{FieldValue};

use AssetLib/FileIO/S4/ClassList/Relations2.{Characteristic, ClassDescription};

// TODO we want to store 002 equi class list as metadata so we can find equipment object type/class
// from field `Asset Type`

pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
/*
    let srcdir  = System/FilePath.new("G:/work/assets/capital_schemes/chell/pdts");
    let srcs    = System/Directory.contents(srcdir) |> Result.getWithDefault(Nil) |> List.filter(x -> System/FilePath.getExtension(x) == Some("xlsx"));
    let dst = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-pdt.sqlite");
    writeDb(srcs, dst) |> println;

*/    
    // tempParse(System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt")) |> println;
    tempClasses() |> println;
    0


def _writeDb(srcs: List[System.FilePath], dst: System.FilePath): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let* relns  = AssetLib/FileIO/PDT/Reader.readFieldValuesAll(srcs);
    let* _      = BasicDb/DbMonad.runSQLite(AssetLib/FileIO/PDT/SQLite.storeFieldValues("pdt_raw_values", relns), dst);
    Ok()

def tempClasses(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let src     = System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt");
    let* relns  = AssetLib/FileIO/S4/ClassList/Relations2.equiClassRelations(src);
    query relns select (x1, x2) from ClassDescription(x1, x2) |> Array.foreach(println);
    query relns select (x1, x2, x3, x4, x5, x6) from Characteristic(x1, x2, x3, x4, x5, x6) |> Array.foreach(println);
    Ok()

def _tempParse(src: System.FilePath): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let* xs = AssetLib/FileIO/S4/ClassList/EquiParser.parseFile(src);
    List.foreach(println, xs);
    Ok()