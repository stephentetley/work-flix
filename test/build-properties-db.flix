use SheetIO/Reader.{XlsxSource};
use AssetLib/Properties/Relations.{StringProperty, IntProperty, FloatProperty};


def main(_: Array[String]): Int32 & Impure = 
    println("Temp1...");
    main01() |> println;
    0
    

def main01(): Result[Int32, String] & Impure = 
    use Result.flatMap;
    let src1    = System/FilePath.new("G:/work/assets/facts/aib_property_types.csv");

    let exports = 
        List.map(makeXlsxSource("G:/work/assets/capital_schemes/bever/"),
                        "bever-agasp-export.xlsx" 
                    ::  "bever-electrical-export.xlsx"
                    ::  "bever-equipment-export.xlsx"
                    ::  "bever-instrument-export.xlsx"
                    ::  "bever-memos-export.xlsx"
                    ::  "bever-pump-export.xlsx"
                    ::  "bever-valve-export.xlsx"
                    ::  Nil);
    let dest    = System/FilePath.new("G:/work/assets/capital_schemes/bever/properties.sqlite");
    let* relns  = AssetLib/Properties/BuildDb.readProperties({typesCsv = src1, exports = exports});
    
    /// query relns select (x1, x2, x3) from StringProperty(x1, x2, x3) |> Array.foreach(println);

    let* _      = AssetLib/Properties/BuildDb.storeProperties(dest, relns);
    Ok(0)

def makeXlsxSource(name1: String, name2: String): XlsxSource = 
    {path = System/FilePath.new("${name1}${name2}"), sheet = "Sheet1"}