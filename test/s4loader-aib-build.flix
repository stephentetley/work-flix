use BasicDb.DbMonad;
use SheetIO/Reader.{XlsxSource};
use S4Loader/Relations.{StringProperty, IntProperty, FloatProperty};


def main(_: Array[String]): Int32 & Impure = 
    use BasicDb/DbMonad.{runSQLite};
    println("Running... ${Time/LocalTime.now()}");
    getIsoLocalDateTimeAsString() |> println;
    runSQLite(buildDb(), System/FilePath.new("G:/work/assets/capital_schemes/bever/properties.sqlite"))
        |> println;
    sqliteDate("M/d/yy H:m") |> println;
    0

def sqliteDate(patt: String): Option[Time.LocalDate] =
    use Option.flatMap;
    let* fmt    = Time/Format/DateTimeFormatter.ofPattern(patt);
    let* dt     = Time/LocalDateTime.parse(fmt, "4/29/21 17:47");
    Some(Time/LocalDateTime.toLocalDate(dt))

def getIsoLocalDateTimeAsString(): String & Impure = 
    let dt = Time/LocalDateTime.now();
    let fmt = Time/Format/DateTimeFormatter.iso_local_date_time();
    let s   = Time/LocalDateTime.format(fmt, dt);
    s


def buildDb(): DbMonad[Int32] = 
    use BasicDb/DbMonad.{flatMap, point};
    let src1    = System/FilePath.new("E:/coding/work/work-flix/data/aib_property_types.csv");
    // let src2    = System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt");
    let src3    = System/FilePath.new("E:/coding/work/work-flix/data/aib_property_aliases.csv");
    let src4    = System/FilePath.new("G:/work/assets/facts/ztables/ztable-manuf-model.txt");
    let src5    = System/FilePath.new("G:/work/assets/facts/ztables/ztable-objtype-manufacturer.txt");

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
    let* _      = S4Loader/Aib/BuildDb.deleteProperties();
    let* n1     = S4Loader/Aib/BuildDb.storeProperties({typesCsv = src1, exports = exports});
    // let* _      = S4Loader/BuildDb.storeS4ClassInfo(src2);
    let* _      = S4Loader/Aib/BuildDb.storePropertyAliases(src3);
    let* _      = S4Loader/Aib/BuildDb.storeZTableManuf(src4);
    let* _      = S4Loader/Aib/BuildDb.storeZTableObj(src5);
    point(n1)

def makeXlsxSource(name1: String, name2: String): XlsxSource = 
    {path = System/FilePath.new("${name1}${name2}"), sheet = "Sheet1"}
    