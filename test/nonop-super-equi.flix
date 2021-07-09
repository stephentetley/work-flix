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


pub def uxlOutputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "SuperEqui for Existing Sites Batch ##"
    , outpath = System/FilePath.new("G:/work/assets/non-op-bins/output/existing-site-superequi-uxl-output##.xlsx")
    }


def main1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let outputArgs      = uxlOutputArgs();
    let aibReport       = System/FilePath.new("G:/work/assets/non-op-bins/AI2NonOp_S4ImportBatches.xlsx");
    let aibSource       = {sheet = "NonOpStatus_S4Presence", path = aibReport};    
    let* equiFacts      = AssetScripts/NonOp/Loader.readSuperEquipFacts(aibSource);
    let* _              = AssetScripts/NonOp/SuperEquipment.genEquiUxl(aibSource, equiFacts, outputArgs);
    Console.printLine("Output dir: ${System/FilePath.getParent(outputArgs.outpath)}");
    Ok()


