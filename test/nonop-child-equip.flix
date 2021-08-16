use SheetIO.NamedRowEvaluator;
use SheetIO.RowEvaluator;
use SheetIO.SheetReader;
use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};

    

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match main1() {
        case Ok() => Console.printLine("Ok")
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    0



pub def uxlOutputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "Subord Equipment for Existing Sites Batch ##"
    , outpath = System/FilePath.new("G:/work/assets/non-op-bins/output/existing-site-subord-equip-uxl-output##.xlsx")
    }


def main1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let outputArgs      = uxlOutputArgs();
    let srcs            = 
        { aibReport = 
            { path = System/FilePath.new("G:/work/assets/non-op-bins/AI2NonOp_S4ImportBatches.xlsx")
            , sheet = "NonOpStatus_S4Presence" }
        , equipmentMapping = 
            { path = System/FilePath.new("G:/work/assets/non-op-bins/equipment-mapping3.xlsx")
            , sheet = "Equi_mapping" }
        , installationMapping = 
            { path = System/FilePath.new("G:/work/assets/non-op-bins/InstallationsMapping_.xlsx")
            , sheet = "Sheet1" }
        , siteEastNorth = 
            { path = System/FilePath.new("G:/work/assets/non-op-bins/allsites-ih06-east_north.xlsx")
            , sheet = "Sheet1" }
        , ztableObjManu = System/FilePath.new("G:/work/assets/facts/ztables/ztable-objtype-manufacturer.txt")
        , ztableManuModel = System/FilePath.new("G:/work/assets/facts/ztables/ztable-manufacturer-model.txt")
        , aibSerialNumbers = 
            { path = System/FilePath.new("G:/work/assets/non-op-bins/aib-nonop-serial-numbers.xlsx")
            , sheet = "Sheet1" }
        , aibPandiTags = 
            { path = System/FilePath.new("G:/work/assets/non-op-bins/aib-nonop-pandi-tags.xlsx")
            , sheet = "Sheet1" }
        , ih08PliNumExport = 
            Some({ path = System/FilePath.new("G:/work/assets/non-op-bins/superequi-ih08-report.xlsx")
                , sheet = "Sheet1"})
        };
    let* _              = AssetScripts/NonOp/SuperEqui.genPlantItemChilds(srcs, outputArgs);
    Console.printLine("Output dir: ${System/FilePath.getParent(outputArgs.outpath)}");
    Ok()


