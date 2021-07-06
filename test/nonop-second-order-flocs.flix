use SheetIO.NamedRowEvaluator;
use SheetIO.RowEvaluator;
use SheetIO.SheetReader;
use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
use AssetScripts/NonOp/Relations.{SecondOrderFlocWorkItem, SiteEastNorth};

    

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running...");
    main1();
    0

pub def uxlOutputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "ACH Flocs for Existing Sites"
    , outpath = System/FilePath.new("G:/work/assets/non-op-bins/output/existing-site-new-flocs-uxl-output1.xlsx")
    }


def main1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let outputArgs  = uxlOutputArgs();
    let aibReport   = System/FilePath.new("G:/work/assets/non-op-bins/AI2NonOp_S4ImportBatches.xlsx");
    let sitesAIB    = System/FilePath.new("G:/work/assets/non-op-bins/sitelist-ih06-aib_reference.xlsx");
    let sitesEN     = System/FilePath.new("G:/work/assets/non-op-bins/sitelist-ih06-east_north.xlsx");
    let* siteMap    = AssetScripts/NonOp/Loader.readSiteFlocs("Sheet1", sitesAIB);
    let* eastNorthMap = AssetScripts/NonOp/Loader.readSiteEastNorth("Sheet1", sitesEN);
    let* worklist = AssetScripts/NonOp/Loader.readSecondOrderFlocWorkItems("NonOpStatus_S4Presence", aibReport);
    let* _ = AssetScripts/NonOp/SecondOrderFlocs.genFlocUxl(worklist <+> siteMap <+> eastNorthMap, outputArgs);
    Console.printLine("Wrote: ${outputArgs.outpath}");
    Ok()

