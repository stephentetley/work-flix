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
    , changeRequestName = "PlantEquip for Existing Sites Batch ##"
    , outpath = System/FilePath.new("G:/work/assets/non-op-bins/output/existing-site-plant-equip-uxl-output##.xlsx")
    }


def main1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let outputArgs      = uxlOutputArgs();
    let srcs            = 
        { aibReport = { sheet = "NonOpStatus_S4Presence"
            , path = System/FilePath.new("G:/work/assets/non-op-bins/AI2NonOp_S4ImportBatches.xlsx")}
        , equipmentMapping = { sheet = "PlantEquip" 
            , path = System/FilePath.new("G:/work/assets/non-op-bins/equipment-mapping2.xlsx")}
        , installationMapping = { sheet = "Sheet1" 
            , path = System/FilePath.new("G:/work/assets/non-op-bins/InstallationsMapping_.xlsx")}
        , siteEastNorth = { sheet = "Sheet1" 
            , path = System/FilePath.new("G:/work/assets/non-op-bins/allsites-ih06-east_north.xlsx")}
        };
    let* _              = AssetScripts/NonOp/PlantEquip.genEquiUxl(srcs, outputArgs);
    Console.printLine("Output dir: ${System/FilePath.getParent(outputArgs.outpath)}");
    Ok()


