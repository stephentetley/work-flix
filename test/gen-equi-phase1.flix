use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
use AssetLib/GenS4/WorkLists.{EquiWorkItem};
use AssetLib/GenS4/GenEqui.{GenEquiArguments};
use AssetLib/GenS4/XlsxSource.{XlsxSource};

pub def uxlOutputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "Brig Upper OC"
    , outpath = System/FilePath.new("G:/work/assets/capital_schemes/hudub/output/hudub-oc-equi-uxl-output1.xlsx")
    }

def genEquiArgs(): GenEquiArguments = 
    { workList = 
        {path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-oc-equi-worklist.xlsx"), sheet = "Sheet1"}
    , aibEquipmentExport = 
        {path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-oc-equipment-export.xlsx"), sheet = "Sheet1"}
    , aibMemosExport = 
        {path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-oc-memo-export.xlsx"), sheet = "Sheet1"}
    }


def main(_args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match genPhase1() {
        case Ok() => ()
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    Console.printLine("Done... ${Time/LocalTime.now()}");
    0

def genPhase1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let equiArgs    = genEquiArgs();
    let emitArgs    = uxlOutputArgs();
    let* equis      = AssetLib/GenS4/GenEqui.generateEquiUxl(equiArgs);
    let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(true, emitArgs, equis);
    let _           = Console.printLine("Wrote: ${emitArgs.outpath}");
    Ok()


