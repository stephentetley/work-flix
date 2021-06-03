use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
use AssetLib/GenS4/GenEqui.{GenEquiArguments};

pub def uxlOutputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "R/1374/003 Rivelin WTW Hypo (BF) 20/04/2021"
    , outpath = System/FilePath.new("G:/work/assets/capital_schemes/rivel/output/uxl-output1.xlsx")
    }

def genEquiArgs(): GenEquiArguments = 
    { uxlArgs = uxlOutputArgs()
    , worklist = 
        {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-sodium-hypo-worklist.xlsx"), sheet = "Sheet1"}
    , aibHierarchyExport = 
        {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-equipment-export.xlsx"), sheet = "Sheet1"} 
    , aibEquipmentExport = 
        {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-equipment-export.xlsx"), sheet = "Sheet1"}
    , aibMemosExport = 
        {file = System/FilePath.new("G:/work/assets/capital_schemes/rivel/rivel-memo-export.xlsx"), sheet = "Sheet1"}
    }


def main(_args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    let args1 = genEquiArgs();
    let ans = AssetLib/GenS4/GenEqui.emitEquiUxl(args1);
    match ans {
        case Ok() => Console.printLine("Success, wrote ${args1.uxlArgs.outpath}")
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    Console.printLine("Done... ${Time/LocalTime.now()}");
    0