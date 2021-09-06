/// This is a temporary script until UXLoader can properly handle floating point values

use SheetIO/Reader.{XlsxSource};
use AssetLib/GenS4/GenEqui.{Phase2GenEquiArguments, FileUploadOutputArgs};



def genEquiArgs(): Phase2GenEquiArguments = 
    { workList = 
        {path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-oc-equi-worklist.xlsx"), sheet = "Sheet1"}
    , s4ChangeRequestEquiTab = System/FilePath.new("G:/work/assets/capital_schemes/hudub/fake-equitab.xlsx")
    , aibElectricalExport = 
        Some({path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-oc-electrical-export.xlsx"), sheet = "Sheet1"})
    , aibInstrumentExport = 
        Some({path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-oc-instrument-export.xlsx"), sheet = "Sheet1"})
    , aibLiftingExport = None
    , aibPumpExport = None
    , aibTankExport = None
    , aibValveExport = None
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



    
  