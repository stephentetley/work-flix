/// This is a temporary script to work out how we make the S4Lite backend configurable
/// and how we can collect configurable sets of facts.

use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
use AssetLib/GenS4/WorkLists.{EquipmentWorkItem};
use AssetLib/GenS4/GenEqui.{GenEquiArguments};
use AssetLib/GenS4/XlsxSource.{XlsxSource};

pub def uxlOutputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "R/1374/003 Rivelin WTW Hypo (BF) 20/04/2021"
    , outpath = System/FilePath.new("G:/work/assets/capital_schemes/rivel/output/rivelin-uxl-output1.xlsx")
    }

def genEquiArgs(): GenEquiArguments = 
    { workList = 
        {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-sodium-hypo-worklist.xlsx"), sheet = "Sheet1"}
    , aibEquipmentExport = 
        {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-equipment-export.xlsx"), sheet = "Sheet1"}
    , aibMemosExport = 
        {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-memo-export.xlsx"), sheet = "Sheet1"}
    }

def genFlocSource(): XlsxSource = 
    {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-sodium-hypo-worklist.xlsx"), sheet = "New_Flocs"}

def main(_args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match genRivelPhase2() {
        case Ok() => ()
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    Console.printLine("Done... ${Time/LocalTime.now()}");
    0

def _genRivelPhase1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let equiArgs    = genEquiArgs();
    let uxlArgs     = uxlOutputArgs();
    let* flocs      = AssetLib/GenS4/GenFlocs.generateFlocUxl(genFlocSource());
    let* equis      = AssetLib/GenS4/GenEqui.generateEquiUxl(equiArgs);
    let uxl         = AssetLib/S4Lite/Datatypes.combineUxlSource(flocs, equis);
    let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(uxl, uxlArgs);
    let _           = Console.printLine("Wrote: ${uxlArgs.outpath}");
    Ok()

def _genFlocEastNorthUpload(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let flocArgs    = genFlocSource();
    let outdir      = System/FilePath.new("G:/work/assets/capital_schemes/rivel/output/");
    let* xs         = AssetLib/GenS4/WorkLists.readFlocWorkList(flocArgs.sheet, flocArgs.file);
    let _           = Console.printLine("Floc work list length: ${List.length(xs)}");
    let* flocchars  = AssetLib/GenS4/Rules/Characteristics/EastNorth.genFlocEastNorth(xs);    
    let _           = Console.printLine("flocchars length: ${Chain.length(flocchars)}");
    let* _          = AssetLib/S4Lite/EmitUpload.outputFlocUploads("tetleys", flocchars, "rivel", outdir);
    Ok()

/// ACTU
/// FSTN
/// LSTN
/// PSTN
/// PUMP
/// SOLE
/// TANK
/// TSTN
/// VALV

type alias Phase2Step = List[EquipmentWorkItem] ~> Result[Chain[SLEquiCharacteristic], String]

def eastNorth(): Phase2Step = xs -> 
    let src = {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-equipment-export.xlsx"), sheet = "Sheet1"};
    AssetLib/GenS4/Rules/Characteristics/EastNorth.genEquiEastNorth(xs, src) 

def assetCondition(): Phase2Step = xs -> 
    let src = {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-agasp-export.xlsx"), sheet = "Sheet1"};
    AssetLib/GenS4/Rules/Characteristics/AssetCondition.genAssetCondition(xs, src) 

def genRivelPhase2(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let equiArgs    = genEquiArgs();
    let outdir      = System/FilePath.new("G:/work/assets/capital_schemes/rivel/output/");
    let* xs         = AssetLib/GenS4/WorkLists.readEquiWorkList(equiArgs.workList.sheet, equiArgs.workList.file);    
    let _           = Console.printLine("xs length: ${List.length(xs)}");
    let* c1         = assetCondition()(xs);
    let* c2         = eastNorth()(xs);
    let _           = Console.printLine("c1 length: ${Chain.length(c1)}");
    let cs          = Monoid.combineAll(c1 :: c2 :: Nil);
    let* _          = AssetLib/S4Lite/EmitUpload.outputEquiUploads("tetleys", cs, "rivel", outdir);
    Ok()