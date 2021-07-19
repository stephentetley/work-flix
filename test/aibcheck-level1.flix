
use AibRefCheck/CalcLevel1.{MissingRef};

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main01() |> println;
    0


def main01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src = 
        { level1SiteMapping     = {sheet = "Sheet1", path = System/FilePath.new("G:/work/assets/aibref-cleanse/SiteMapping_Level2.xlsx")}
        , ih06SiteExport        = {sheet = "Sheet1", path = System/FilePath.new("G:/work/assets/aibref-cleanse/s4-all-sites-with-aib_ai2_reference.xlsx")}
        , valuaFlocDownloads    = System/FilePath.new("G:/work/assets/aibref-cleanse/level1/downloads/")
        };
    let outdir      = System/FilePath.new("G:/work/assets/aibref-cleanse/level1/output/");
    let* mm         = AibRefCheck/Level1/Loader.readValCountFiles(src.valuaFlocDownloads);
    let* db         = AibRefCheck/Level1/CalcLevel1.readSource(src);
    let missing     = AibRefCheck/Level1/CalcLevel1.getMissingRefs(db);
    let xs          = query missing select (x,y,z) from MissingRef(x,y,z) |> Array.toList;
    let xss         = AibRefCheck/Level1/CalcLevel1.makeMissingValuaFlocs(mm, xs);
    let _           = AibRefCheck/Level1/CalcLevel1.writeValuaFlocFiles(outdir, xss);
    Ok()