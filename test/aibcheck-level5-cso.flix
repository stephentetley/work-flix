
use AibRefCheck/Level5Cso.{CsoWithFLS, CsoWithoutFLS};

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main01() |> println;
    0


def main01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src = 
        { siteMapping   = {path = System/FilePath.new("G:/work/assets/aibref-cleanse/AI2toS4Hana_Lvl1_5FlocMapping_V17.xlsx")
                            , sheet = "inst to SAP migration"}
        , ih06Export    = {path = System/FilePath.new("G:/work/assets/aibref-cleanse/Level5_cso-WTN-SOF-FLS.xlsx")
                            , sheet = "Sheet1"}
        };
    let outpath     = System/FilePath.new("G:/work/assets/aibref-cleanse/flow-spilling-report.xlsx");
    let* db         = AibRefCheck/Level5Cso.readSource(src);
    let solns       = AibRefCheck/Level5Cso.genAnswers(db);
    let* _          = AibRefCheck/Level5Cso.exportAnswers(solns, outpath);
    let _           = Console.printLine("CSO with FLS...");
    let _           = query solns select (x,y,z) from CsoWithFLS(x,y,z) |> Array.foreach(println);
    let _           = Console.printLine("CSO missing FLS...");
    let _           = query solns select (x,y) from CsoWithoutFLS(x,y) |> Array.foreach(println);
    Ok()