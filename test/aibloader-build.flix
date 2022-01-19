use BasicDb.DbMonad;
use SheetIO/Reader.{XlsxSource};
use AibLoader/Relations.{StringProperty, IntProperty, FloatProperty};


def main(_: Array[String]): Int32 & Impure = 
    use BasicDb/DbMonad.{runSQLite};
    println("Running... ${Time/LocalTime.now()}");
    runSQLite(buildDb(), System/FilePath.new("G:/work/assets/capital_schemes/bever/properties.sqlite"))
        |> println;
    0
    

def buildDb(): DbMonad[Int32] = 
    use BasicDb/DbMonad.{flatMap, point};
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
    let* _      = AibLoader/BuildDb.storeProperties({typesCsv = src1, exports = exports});
    let* _      = AibLoader/BuildDb.storeS4ClassInfo(src2);
    let* _      = AibLoader/BuildDb.storePropertyAliases(src3);
    point(0)

def makeXlsxSource(name1: String, name2: String): XlsxSource = 
    {path = System/FilePath.new("${name1}${name2}"), sheet = "Sheet1"}
    