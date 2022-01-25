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
    // tempClasses() |> println;
*/    
    tempParse() |> println;
    0


def _writeDb(srcs: List[System.FilePath], dst: System.FilePath): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let* relns  = AssetLib/FileIO/PDT/Reader.readFieldValuesAll(srcs);
    let* _      = BasicDb/DbMonad.runSQLite(AssetLib/FileIO/PDT/SQLite.storeFieldValues("pdt_raw_values", relns), dst);
    Ok()

def _tempClasses(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let src     = System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt");
    let* relns  = AssetLib/FileIO/S4/ClassList/Relations2.equiClassRelations(src);
    query relns select (x1, x2) from ClassDescription(x1, x2) |> Array.foreach(println);
    query relns select (x1, x2, x3, x4, x5, x6) from Characteristic(x1, x2, x3, x4, x5, x6) |> Array.foreach(println);
    Ok()

def tempParse(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    println("tempParse()");
    
    let classline = "  |--      002 ACPTHA                             Hatchbox Access Point                   X";
    // Note - classpatt1 needs the suffix 'X' (also need a classpatt2 without it)
    // let* classpatt1 = Text/Regex/Pattern.compile("[\\u0020\\u002D\\u007C]{11}002 (?<classname>[\\p{Print}\\u0020]{34}) (?<classdesc>[\\p{Print}\\u0020]{40})X");
    // Text/Regex.matches(classpatt1, classline) |> println;
    classline |> AssetLib/FileIO/S4/ClassList/EquiParser.classRow1() |> println;

    let charline = "  |   |--      ACPT_DEPTH_M                       Depth (m)                                          NUM       4         2";
     let* charpatt1 = Text/Regex/Pattern.compile("[\\u0020\\u002D\\u007C]{15}(?<charname>[\\p{Print}\\u0020]{34}) (?<chardesc>[\\p{Print}\\u0020]{50}) (?<chartype>[\\p{Upper}\\u0020]{9}) (?<length>\\p{Digit}+) (\\u0020*)(?<decimals>\\p{Digit}+)");
    Text/Regex.matches(charpatt1, charline) |> println;
    let valline = "  |   |   |--      155 (CLASS F)";
    // Note - valpatt matches a range or value (need disambiguation later)
    let* valpatt = Text/Regex/Pattern.compile("[\\u0020\\u002D\\u007C]{19}(?<value>.+)");
    Text/Regex.matches(valpatt, valline) |> println;
    Ok()