use SheetIO.NamedRowEvaluator;
use SheetIO.RowEvaluator;
use SheetIO.SheetReader;
use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
use AssetScripts/NonOp/Relations.{SecondOrderFlocWorkItem, SiteEastNorth};

    

def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    match main1() {
        case Ok() => println("Ok")
        case Err(msg) => println("Error: ${msg}")
    };
    0



pub def uxlOutputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "Lifting equip for Added Sites Batch ##"
    , outpath = System/FilePath.new("G:/work/assets/non-op-bins/output/added-site-lift-equip-uxl-output##.xlsx")
    }


def main1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let outputArgs      = uxlOutputArgs();
    let srcs            = 
        { aibReport = { sheet = "NonOpStatus_NoS4Presence"
            , path = System/FilePath.new("G:/work/assets/non-op-bins/AI2NonOp_S4ImportBatches.xlsx")}
        , equipmentMapping = { sheet = "Equi_mapping"
            , path = System/FilePath.new("G:/work/assets/non-op-bins/equipment-mapping3.xlsx")}
        , installationMapping = { sheet = "Sheet1" 
            , path = System/FilePath.new("G:/work/assets/non-op-bins/InstallationsMapping_.xlsx")}
        , siteEastNorth = { sheet = "Sheet1" 
            , path = System/FilePath.new("G:/work/assets/non-op-bins/allsites-ih06-east_north.xlsx")}
        , ztableObjManu = System/FilePath.new("G:/work/assets/facts/ztables/ztable-objtype-manufacturer.txt")
        , ztableManuModel = System/FilePath.new("G:/work/assets/facts/ztables/ztable-manufacturer-model.txt")
        , aibSerialNumbers= { sheet = "Sheet1" 
            , path = System/FilePath.new("G:/work/assets/non-op-bins/aib-nonop-serial-numbers.xlsx")}
        , aibPandiTags= { sheet = "Sheet1" 
            , path = System/FilePath.new("G:/work/assets/non-op-bins/aib-nonop-pandi-tags.xlsx")}
        , ih08PliNumExport = None
        };
    let* _              = AssetScripts/NonOp/SuperEqui.genPlantItemNoParentUxl(srcs, outputArgs);
    println("Output dir: ${System/FilePath.getParent(outputArgs.outpath)}");
    Ok()


