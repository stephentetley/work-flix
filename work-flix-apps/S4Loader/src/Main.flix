
/// TODO make this a proper `main` with GetOpt or JSON params etc.

use Applicative.{*>};
use BasicDb.DbMonad;
use SheetIO/Reader.{XlsxSource};
use S4Loader/Base/Schema.{S4Properties, StringProperty, IntProperty, FloatProperty};


def main(_: Array[String]): Int32 & Impure = 
    use BasicDb/DbMonad.{runSQLite};
    println("Running S4Loader... ${Time/LocalTime.now()}");
    let metaSources = 
        { equiClassList = System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt")
        , fieldTypes = System/FilePath.new("E:/coding/work/work-flix/data/S4Loader_configs/pdt_field_types.csv")
        , assetTypes = System/FilePath.new("E:/coding/work/work-flix/data/S4Loader_configs/pdt_asset_types.csv")
        };
    let pdtDb = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-dsear-pdt.sqlite");
    let dst = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-dsear-s4loader.sqlite");
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
                            fieldTypes :: System.FilePath,
                            assetTypes :: System.FilePath}, 
            pdtDb: System.FilePath): DbMonad[S4Properties[r1]] = 
    use BasicDb/DbMonad.{flatMap, point};
    let* _  = S4Loader/PDT/BuildDb.initDb();
    let* r1 = S4Loader/PDT/BuildDb.storeMetaData(metaSources);
    let* r2 = S4Loader/PDT/BuildDb/MakeProperties.readPDTRawValues(pathToPdtDb = pdtDb, "pdt_values_with_item_name");
    let ans = S4Loader/PDT/BuildDb/MakeProperties.genProperties(r1 <+> r2);
    let* _  = S4Loader/Base/StoreProperties.storeProperties(ans);
    point(ans)

