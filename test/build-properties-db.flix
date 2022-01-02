use SheetIO/Reader.{XlsxSource};


def main(_: Array[String]): Int32 & Impure = 
    println("Temp1...");
    let src1 = {path = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-equipment-export.xlsx"), 
                sheet = "Sheet1"};
    let src2 = System/FilePath.new("G:/work/assets/facts/aib_property_types.csv");
    readExport(src1) |> println;
    readAibTypes(src2) |> println;
    0


def readExport(src: XlsxSource): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use AssetLib/Properties/BuildDb.{UniProperty};
    let* relns = AssetLib/Properties/BuildDb.readAibExport(src);
    query relns select (x1, x2, x3) from UniProperty(x1, x2, x3) 
        |> Array.foreach(println);
    
    Ok()

def readAibTypes(src: System.FilePath): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use AssetLib/Properties/BuildDb.{AibType};
    let* relns = AssetLib/Properties/BuildDb.readAibTypes(src);
    query relns select (x1, x2) from AibType(x1, x2) 
        |> Array.foreach(println);
    
    Ok()