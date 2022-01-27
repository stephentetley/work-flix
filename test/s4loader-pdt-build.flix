use Applicative.{*>};
use BasicDb.DbMonad;
use SheetIO/Reader.{XlsxSource};
use S4Loader/Relations.{StringProperty, IntProperty, FloatProperty};


def main(_: Array[String]): Int32 & Impure = 
    use BasicDb/DbMonad.{runSQLite};
    println("Running... ${Time/LocalTime.now()}");
    let dst = System/FilePath.new("G:/work/assets/capital_schemes/chell/s4loader.sqlite");
    let metaSources = {
        equiClassList = System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt")
    };
    let overwrite = true;
    if (System/IO.fileExists(dst) != Ok(true) or overwrite == true)
        runSQLite(S4Loader/Pdt/BuildDb.initDb() *> S4Loader/Pdt/BuildDb.storeMetaData(metaSources), dst) |> println
    else
        ();

/*
    runSQLite(buildDb(), System/FilePath.new("G:/work/assets/capital_schemes/chell/s4loader.sqlite"))
        |> println;
*/
    println("Done.");
    0


/*
def buildDb(): DbMonad[Int32] = 
    use BasicDb/DbMonad.{flatMap, point};

    // let src2    = System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt");
    let src3    = System/FilePath.new("E:/coding/work/work-flix/data/aib_property_aliases.csv");
    let src4    = System/FilePath.new("G:/work/assets/facts/ztables/ztable-manuf-model.txt");
    let src5    = System/FilePath.new("G:/work/assets/facts/ztables/ztable-objtype-manufacturer.txt");

    let* _      = S4Loader/Aib/BuildDb.deleteProperties();
    let* n1     = S4Loader/Aib/BuildDb.storeProperties({typesCsv = src1, exports = exports});
    // let* _      = S4Loader/BuildDb.storeS4ClassInfo(src2);
    let* _      = S4Loader/Aib/BuildDb.storePropertyAliases(src3);
    let* _      = S4Loader/Aib/BuildDb.storeZTableManuf(src4);
    let* _      = S4Loader/Aib/BuildDb.storeZTableObj(src5);
    point(n1)

def makeXlsxSource(name1: String, name2: String): XlsxSource = 
    {path = System/FilePath.new("${name1}${name2}"), sheet = "Sheet1"}
*/