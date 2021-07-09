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

/// def _test01(): Int32 & Impure =     
///     AssetLib/Base/Utils.properCaseName("NO 2 INLET SCREENS BOOSTER PUMP") |> println;
///     let pgdesc = "PRELIMINARY TREATMENT-STW";
///     let pdesc = "SCREENING";
///     let commonName = "BALBY/STW/PRELIMINARY TRT-STW/SCREENING/NO 1 INLET SCREENS BOOSTER PUMP";
///     (String.breakOnRight("${pgdesc}/${pdesc}/", commonName)) |> println;
///     0

/// def test02(): Int32 & Impure =     
///     let printX = ks -> List.formatWith(x -> x, "", ks) |> println; 
///     let xs = List.repeat("#", 1005);
///     let xxs = AssetScripts/NonOp/Utils.sublists(40, xs);
///     List.foreach(printX, xxs);
///     0



pub def uxlOutputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "SuperEqui for Existing Sites Batch ##"
    , outpath = System/FilePath.new("G:/work/assets/non-op-bins/output/existing-site-superequi-uxl-output##.xlsx")
    }


def main1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let outputArgs      = uxlOutputArgs();
    let aibSource       = {sheet = "NonOpStatus_S4Presence", 
                            path = System/FilePath.new("G:/work/assets/non-op-bins/AI2NonOp_S4ImportBatches.xlsx")};                            
    let sitesSource     = {sheet = "Sheet1", 
                            path = System/FilePath.new("G:/work/assets/non-op-bins/SiteMapping_.xlsx")};
    let tagsSource      = {sheet = "Sheet1", 
                            path = System/FilePath.new("G:/work/assets/non-op-bins/aib-nonop-pandi-tags.xlsx")};
    let equiMapSource   = {sheet = "PlantEquip", 
                            path = System/FilePath.new("G:/work/assets/non-op-bins/equipment-mapping2.xlsx")};
    let* equiFacts      = AssetScripts/NonOp/Loader.readSuperEquipFacts(aibSource);
    let* pandi          = AssetScripts/NonOp/Loader.readPandITags(tagsSource);
    let* sites          = AssetScripts/NonOp/Loader.readInstallationMappings(sitesSource);
    let* equiMap        = AssetScripts/NonOp/Loader.readEquipmentMapping(equiMapSource);
    let* _              = AssetScripts/NonOp/SuperEquipment.genEquiUxl(aibSource, equiFacts <+> pandi <+> sites <+> equiMap, outputArgs);
    Console.printLine("Output dir: ${System/FilePath.getParent(outputArgs.outpath)}");
    Ok()


