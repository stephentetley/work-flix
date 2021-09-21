/// This is a temporary script until UXLoader can properly handle floating point values

use SheetIO/Reader.{XlsxSource};
use AssetLib/GenS4/GenPhase2Uploads.{Phase2GenEquiArguments, FileUploadOutputArgs};



def genEquiArgs(): Phase2GenEquiArguments = 
    { workList = 
        {path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-wwp-combined-worklist.xlsx"), sheet = "Equi_Worklist"}
    , s4ChangeRequestEquiTab = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-wwp-s4-equitab-export.xlsx")
    , aibElectricalExport = 
        Some({path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-wwp-electrical-export.xlsx"), sheet = "Sheet1"})
    , aibFanExport = None
    , aibInstrumentExport = 
        Some({path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-wwp-instrument-export.xlsx"), sheet = "Sheet1"})
    , aibLiftingExport = None
    , aibPumpExport = 
        Some({path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-wwp-pump-export.xlsx"), sheet = "Sheet1"})
    , aibTankExport = None
    , aibValveExport = 
        Some({path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-wwp-valve-export.xlsx"), sheet = "Sheet1"})
    }


def genOutputArgs(): FileUploadOutputArgs = 
    { outputDirectory = System/FilePath.new("G:/work/assets/capital_schemes/hudub/output")
    , userName = "tetleys"
    , filePrefix = "hudub-wwp"
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
    let* _          = AssetLib/GenS4/GenPhase2Uploads.generatePhase2EquiUploads(equiArgs, outputArgs);
    let _           = Console.printLine("Wrote files to: ${outputArgs.outputDirectory}");
    Ok()



    
  