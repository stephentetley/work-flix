use SheetIO/Reader.{XlsxSource};
use AssetLib/Properties/Relations.{StringProperty, IntProperty, FloatProperty};


def main(_: Array[String]): Int32 & Impure = 
    println("Temp1...");
    main01() |> println;
    0
    

def main01(): Result[Int32, String] & Impure = 
    use Result.flatMap;
    let src1    = System/FilePath.new("G:/work/assets/facts/aib_property_types.csv");

    let src2    = {path = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-agasp-export.xlsx"), 
                    sheet = "Sheet1"};
    let src3    = {path = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-equipment-export.xlsx"), 
                    sheet = "Sheet1"};
    let dest    = "jdbc:sqlite:g:/work/assets/capital_schemes/bever/properties.sqlite";
    let* relns  = AssetLib/Properties/BuildDb.readProperties({typesCsv = src1, exports = src2 :: src3 :: Nil});
    
    /// query relns select (x1, x2, x3) from StringProperty(x1, x2, x3) |> Array.foreach(println);

    let* _      = AssetLib/Properties/BuildDb.storeProperties(dest, relns);
    Ok(0)

