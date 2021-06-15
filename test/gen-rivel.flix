/// This is a temporary script to work out how we make the S4Lite backend configurable
/// and how we can collect configurable sets of facts.

use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
use AssetLib/GenS4/WorkLists.{EquipmentWorkItem};
use AssetLib/GenS4/GenEqui.{GenEquiArguments};
use AssetLib/GenS4/XlsxSource.{XlsxSource};

pub def uxlOutputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "Elvin (BF)"
    , outpath = System/FilePath.new("G:/work/assets/capital_schemes/rivel/output/rivel-uxl-output1.xlsx")
    }

def genEquiArgs(): GenEquiArguments = 
    { workList = 
        {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-sodium-hypo-worklist.xlsx"), sheet = "Sheet1"}
    , aibEquipmentExport = 
        {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-equipment-export.xlsx"), sheet = "Sheet1"}
    , aibMemosExport = 
        {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-memos-export.xlsx"), sheet = "Sheet1"}
    }

def genFlocSource(): XlsxSource = 
    {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-sodium-hypo-worklist.xlsx"), sheet = "New_Flocs"}

def main(_args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match genRivelPhase1() {
        case Ok() => ()
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    Console.printLine("Done... ${Time/LocalTime.now()}");
    0

def genRivelPhase1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let equiArgs    = genEquiArgs();
    let emitArgs    = uxlOutputArgs();
    let* flocs      = AssetLib/GenS4/GenFlocs.generateFlocUxl(genFlocSource());
    let* equis      = AssetLib/GenS4/GenEqui.generateEquiUxl(equiArgs);
    let uxl         = AssetLib/S4Lite/Datatypes.combineUxlSource(flocs, equis);
    let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(emitArgs, uxl);
    let _           = Console.printLine("Wrote: ${emitArgs.outpath}");
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

/// ACTU    Electrical
/// FSTN    Instrument
/// LSTN    Instrument
/// PSTN    Instrument
/// PUMP    Pump
/// SOLE    Electrical
/// TANK
/// TSTN    Instrument
/// VALV    Valve

type alias Phase2Step = List[EquipmentWorkItem] ~> Result[Chain[SLEquiCharacteristic], String]

def aibReference(): Phase2Step = xs -> 
    let src = {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-equipment-export.xlsx"), sheet = "Sheet1"};
    AssetLib/GenS4/Rules/Characteristics/AibReference.genEquiAibReference(xs, src) 

/// def assetCondition(): Phase2Step = xs -> 
///     let src = {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-agasp-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/AssetCondition.genAssetCondition(xs, src) 

/// def eastNorth(): Phase2Step = xs -> 
///     let src = {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-equipment-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/EastNorth.genEquiEastNorth(xs, src) 

/// def solutionId(): Phase2Step = xs -> 
///     AssetLib/GenS4/Rules/Characteristics/SolutionId.genEquiSolutionId(xs) 

/// def actu(): Phase2Step = xs -> 
///     let src = {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-electrical-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Actu.genActu(xs, src) 

/// def fstn(): Phase2Step = xs -> 
///     let src = {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-instrument-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Fstn.genFstn(xs, src) 

/// def lstn(): Phase2Step = xs -> 
///     let src = {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-instrument-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Lstn.genLstn(xs, src) 

/// def pstn(): Phase2Step = xs -> 
///     let src = {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-instrument-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Pstn.genPstn(xs, src) 

/// def pump(): Phase2Step = xs -> 
///     let src = {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-pump-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Pump.genPump(xs, src) 


/// def sole(): Phase2Step = xs -> 
///     let src = {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-electrical-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Sole.genSole(xs, src) 

/// def tstn(): Phase2Step = xs -> 
///     let src = {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-instrument-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Tstn.genTstn(xs, src) 

/// def valv(): Phase2Step = xs -> 
///     let src = {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-valve-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Valv.genValv(xs, src) 

def phase2Steps(): List[Phase2Step] = 
        aibReference() :: Nil /// assetCondition() :: eastNorth() :: solutionId() 
        /// :: actu() :: fstn() :: lstn() :: pstn() :: pump() :: sole() :: tstn() :: valv() :: Nil


    

def _genRivelPhase2(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let equiArgs    = genEquiArgs();
    let outdir      = System/FilePath.new("G:/work/assets/capital_schemes/rivel/output/");
    let* xs         = AssetLib/GenS4/WorkLists.readEquiWorkList(equiArgs.workList.sheet, equiArgs.workList.file);    
    let _           = Console.printLine("xs length: ${List.length(xs)}");
    let* cs         = runSteps(phase2Steps(), xs);
    let _           = Console.printLine("cs length: ${Chain.length(cs)}");
    let crpath      = System/FilePath.new("G:/work/assets/capital_schemes/rivel/CR7956-rivel-equis.xlsx");
    let renamings   = AssetLib/GenS4/WorkLists.getEquipmentWorkItemKeyMap(xs);
    let* cs1        = AssetLib/S4Lite/EmitUpload.renumberSLEquiCharacteristics(renamings, "Data", crpath, cs);
    let* _          = AssetLib/S4Lite/EmitUpload.outputEquiUploads("tetleys", cs1, "rivel", outdir);
    Ok()

def runSteps(steps: List[Phase2Step], xs: List[EquipmentWorkItem]): Result[Chain[SLEquiCharacteristic], String] & Impure = 
    runStepsHelper(steps, xs, msg -> Err(msg), cs -> Ok(cs))

def runStepsHelper(steps: List[Phase2Step], 
                    xs: List[EquipmentWorkItem], 
                    fk: String -> Result[Chain[SLEquiCharacteristic], String],
                    sk: Chain[SLEquiCharacteristic] -> Result[Chain[SLEquiCharacteristic], String]): Result[Chain[SLEquiCharacteristic], String] & Impure = 
    match steps {
        case Nil => sk(Chain.empty())
        case s1 :: rs => match s1(xs) {
            case Ok(c1) => runStepsHelper(rs, xs, fk, cs -> sk(Monoid.combine(cs, c1)))
            case Err(msg) => fk(msg)
        }
    }    