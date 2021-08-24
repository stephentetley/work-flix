use SheetIO.NamedRowEvaluator;
use SheetIO.RowEvaluator;
use SheetIO.SheetReader;
use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
use AssetScripts/NonOp/Relations.{SecondOrderFlocWorkItem, SiteEastNorth};

    

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match main1() {
        case Ok() => Console.printLine("Ok")
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    /// temp01();
    0

/// Need to be annotated with an index...
pub def uxlOutputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "ACH Flocs for Added Sites Batch ##"
    , outpath = System/FilePath.new("G:/work/assets/non-op-bins/output/nonop-added-flocs2-ACH-uxl##.xlsx")
    }


def main1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let outputArgs      = uxlOutputArgs();
    let worklist        = {sheet = "Sheet1", 
                            path = System/FilePath.new("G:/work/assets/non-op-bins/gen-site-flocs-worklist.xlsx")};
    let* _              = AssetScripts/NonOp/AchFlocs.genFlocUxl(worklist, outputArgs);
    Console.printLine("Output dir: ${System/FilePath.getParent(outputArgs.outpath)}");
    Ok()

