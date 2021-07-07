use SheetIO.NamedRowEvaluator;
use SheetIO.RowEvaluator;
use SheetIO.SheetReader;
use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
use AssetScripts/NonOp/Relations.{SecondOrderFlocWorkItem, SiteEastNorth};

    

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1();
    /// temp01();
    0

/// Need to be annotated with an index...
pub def uxlOutputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "ACH Flocs for Existing Sites Batch ##"
    , outpath = System/FilePath.new("G:/work/assets/non-op-bins/output/existing-site-new-flocs-uxl-output##.xlsx")
    }


def main1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let outputArgs      = uxlOutputArgs();
    let aibReport       = System/FilePath.new("G:/work/assets/non-op-bins/AI2NonOp_S4ImportBatches.xlsx");
    let sitesAIB        = System/FilePath.new("G:/work/assets/non-op-bins/sitelist-ih06-aib_reference.xlsx");
    let sitesEN         = System/FilePath.new("G:/work/assets/non-op-bins/sitelist-ih06-east_north.xlsx");
    let* siteMap        = AssetScripts/NonOp/Loader.readSiteFlocs({sheet = "Sheet1", path = sitesAIB});
    let* eastNorthMap   = AssetScripts/NonOp/Loader.readSiteEastNorth({sheet = "Sheet1", path = sitesEN});
    let worklist        = {sheet = "NonOpStatus_S4Presence", path = aibReport};
    let* _ = AssetScripts/NonOp/SecondOrderFlocs.genFlocUxl(worklist, siteMap <+> eastNorthMap, outputArgs);
    Console.printLine("Wrote: ${outputArgs.outpath}");
    Ok()

/// def temp01(): Result[Unit, String] & Impure = 
///     use Result.{flatMap};
///     println(">>>");
///     let xs = "one" :: "two" :: "three" :: "four" :: "five" :: "six" :: "seven" :: Nil;
///     AssetScripts/NonOp/Utils.sublists(3, xs) |> List.foreach(println);
///     println(">>>");
///     AssetScripts/NonOp/Utils.divide(2, xs) |> List.foreach(println);
///     println(">>>");
///     let ys = "1" :: "2" :: "3" :: "4" :: "5" :: "6" :: Nil;
///     AssetScripts/NonOp/Utils.divide(2, ys) |> List.foreach(println);
///     println(">>> 6 / 4");
///     AssetScripts/NonOp/Utils.divide(4, ys) |> List.foreach(println);
///     println(">>> 6 / 5");
///     AssetScripts/NonOp/Utils.divide(5, ys) |> List.foreach(println);
///     println(">>>");
///     Ok()
