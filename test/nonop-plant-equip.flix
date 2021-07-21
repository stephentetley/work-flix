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
    0



pub def uxlOutputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "SuperEqui for Existing Sites Batch ##"
    , outpath = System/FilePath.new("G:/work/assets/non-op-bins/output/existing-site-superequi-uxl-output##.xlsx")
    }


def main1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let outputArgs      = uxlOutputArgs();
    let reportSource       = {sheet = "NonOpStatus_S4Presence", 
                                path = System/FilePath.new("G:/work/assets/non-op-bins/AI2NonOp_S4ImportBatches.xlsx")};                            
    let* _              = AssetScripts/NonOp/PlantEquip.genEquiUxl(reportSource, outputArgs);
    Console.printLine("Output dir: ${System/FilePath.getParent(outputArgs.outpath)}");
    Ok()


