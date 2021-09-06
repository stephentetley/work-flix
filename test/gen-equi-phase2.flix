/// This is a temporary script until UXLoader can properly handle floating point values

use SheetIO/Reader.{XlsxSource};
use AssetLib/GenS4/GenEqui.{Phase2GenEquiArguments, FileUploadOutputArgs};



def genEquiArgs(): Phase2GenEquiArguments = 
    { workList = 
        {path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-oc-equi-worklist.xlsx"), sheet = "Sheet1"}
    , s4ChangeRequestEquiTab = System/FilePath.new("MISSING.xlsx")
    , aibElectricalExport = 
        {path = System/FilePath.new("MISSING.xlsx"), sheet = "Sheet1"}
    }


def genOutputArgs(): FileUploadOutputArgs = 
    { outputDirectory = System/FilePath.new("G:/work/assets/capital_schemes/hudub/output")
    , userName = "tetleys"
    , filePrefix = "hudub"
    } 


def main(_args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match genPhase2() {
        case Ok() => ()
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    Console.printLine("Done... ${Time/LocalTime.now()}");
    0

def genPhase2(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let equiArgs    = genEquiArgs();
    let outputArgs  = genOutputArgs();
    let* _          = AssetLib/GenS4/GenEqui.emitPhase2EquiUxl(equiArgs, outputArgs);
    let _           = Console.printLine("Wrote files to: ${outputArgs.outputDirectory}");
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



/// def crht(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/lifting-equipment-2021/knost/knost-lifting-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Crht.genCrht(xs, src) 

/// def emtr(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/dri02/driff-electrical-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Emtr.genEmtr(xs, src) 

/// def fstn(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/dri02/driff-instrument-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Fstn.genFstn(xs, src) 


/// def liac(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/lifting-equipment-2021/knost/knost-lifting-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Liac.genLiac(xs, src) 

/// def lisl(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/lifting-equipment-2021/knost/knost-lifting-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Lisl.genLisl(xs, src) 


/// def lstn(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/dri02/driff-instrument-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Lstn.genLstn(xs, src) 

/// def pstn(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/dri02/driff-instrument-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Pstn.genPstn(xs, src) 

/// def pump(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/dri02/driff-pump-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Pump.genPump(xs, src) 

/// def pums(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/dri02/driff-pump-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Pums.genPums(xs, src) 

/// def sole(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/dri02/driff-electrical-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Sole.genSole(xs, src) 

/// def tstn(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/dri02/driff-instrument-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Tstn.genTstn(xs, src) 

/// def valv(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/dri02/driff-valve-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Valv.genValv(xs, src) 

/// def phase2Steps(): List[Phase2Step] = 

///         /// crht()
///            actu() 
///         :: emtr() 
///         :: fstn() 
///         /// :: liac()
///         /// :: lisl()
///         :: lstn() 
///         :: pstn()
///         :: pump()
///         :: pums()
///         :: sole()
///         :: tstn()
///         :: valv()
///         :: Nil

    
  