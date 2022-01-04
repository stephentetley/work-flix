use SheetIO/Reader.{XlsxSource};
use AssetLib/Properties/Relations.{StringProperty, IntProperty, FloatProperty};


def main(_: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    main01() |> println;
    0
    

def main01(): Result[Int32, String] & Impure = 
    use Result.flatMap;
    let src1    = System/FilePath.new("E:/coding/work/work-flix/data/aib_property_types.csv");
    let src2    = System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt");
    let src3    = System/FilePath.new("E:/coding/work/work-flix/data/property_aliases.csv");

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
    let* _      = AssetLib/Properties/BuildDb.storeProperties(dest, relns);

    let* cs     = AssetLib/Properties/BuildDb.readClassList(src2);
    let* _      = AssetLib/Properties/BuildDb.storeS4ClassInfo(dest, cs);

    let* ps     = AssetLib/Properties/BuildDb.readPropertyAliases(src3);
    let* _      = AssetLib/Properties/BuildDb.storePropertyAliases(dest, ps);

    Ok(0)

def makeXlsxSource(name1: String, name2: String): XlsxSource = 
    {path = System/FilePath.new("${name1}${name2}"), sheet = "Sheet1"}