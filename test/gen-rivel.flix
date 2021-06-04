/// This is a temporary script to work out how we make the S4Lite backend configurable
/// and how we can collect configurable sets of facts.

use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
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
    match genEastNorth() {
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

def genEastNorth(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let flocArgs    = genFlocSource();
    let outdir      = System/FilePath.new("G:/work/assets/capital_schemes/rivel/output/");
    let* xs         = AssetLib/GenS4/WorkLists.readFlocWorkList(flocArgs.sheet, flocArgs.file);
    let _           = Console.printLine("Floc work list length: ${List.length(xs)}");
    let* flocchars  = AssetLib/GenS4/Rules/Characteristics/EastNorth.genFlocEastNorth(xs);    
    let _           = Console.printLine("flocchars length: ${List.length(flocchars)}");
    let* _          = AssetLib/S4Lite/EmitUpload.outputFlocUploads("tetleys", flocchars, "rivel", outdir);
    Ok()
