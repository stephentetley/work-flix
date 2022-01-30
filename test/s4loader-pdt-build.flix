use Applicative.{*>};
use BasicDb.DbMonad;
use SheetIO/Reader.{XlsxSource};
use S4Loader/Base/Relations.{AibProperties, StringProperty, IntProperty, FloatProperty};


def main(_: Array[String]): Int32 & Impure = 
    use BasicDb/DbMonad.{runSQLite};
    println("Running... ${Time/LocalTime.now()}");
    let dst = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-s4loader.sqlite");
    let metaSources = 
        { equiClassList = System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt")
        , fieldUnitTypes = System/FilePath.new("E:/coding/work/work-flix/data/S4Loader_configs/pdt_field_unit_types.csv")
        };
    let pdtDb = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-pdt.sqlite");
    let overwrite = true;
    if (System/IO.fileExists(dst) != Ok(true) or overwrite == true)
        match runSQLite(buildDb(metaSources, pdtDb), dst) {
            case Ok(relns) => query relns select (x1, x2, x3) from StringProperty(x1, x2 ,x3) |> Array.foreach(println)
            case Err(e) => println("Error: ${e}")
        }
    else
        ();
    println("Done.");
    0



def buildDb(metaSources: {equiClassList :: System.FilePath, 
                            fieldUnitTypes :: System.FilePath}, 
            pdtDb: System.FilePath): DbMonad[AibProperties[r1]] = 
    use BasicDb/DbMonad.{flatMap, point};
    let* _ = S4Loader/Pdt/BuildDb.initDb();
    let* r1 = S4Loader/Pdt/BuildDb.storeMetaData(metaSources);
    let* r2 = S4Loader/PDT/BuildDb/MakeProperties.readPDTValueRows(pathToPdtDb = pdtDb, "pdt_values_with_item_name");
    let ans = S4Loader/PDT/BuildDb/MakeProperties.genProperties(r1 <+> r2);
    point(ans)

