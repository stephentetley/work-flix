use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
use AssetLib/GenS4/GenUxl.{GenEquiArguments};

def outputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "Hudds Upper Brighouse FE Washwater"
    , outpath = System/FilePath.new("G:/work/assets/capital_schemes/hudub/output/hudub-UXL.xlsx")
    }

def equiArgs(): GenEquiArguments = 
    { aibEquipmentExport = 
        {path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-wwp-equipment-export.xlsx"), sheet = "Sheet1"}
    , aibMemosExport = 
        {path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-wwp-memos-export.xlsx"), sheet = "Sheet1"}
    , aibAgaspExport = 
        {path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-wwp-agasp-export.xlsx"), sheet = "Sheet1"}
    }


def main(_args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    let workList = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-wwp-combined-worklist.xlsx");
    let flocWorkList = {path = workList, sheet = "Floc_Worklist"};
    let equiWorkList = {path = workList, sheet = "Equi_Worklist"};                        
    let ans = AssetLib/GenS4/GenUxl.generateCombinedUxl(flocWorkList, equiWorkList, equiArgs(), outputArgs());
    match ans {
        case Ok() => Console.printLine("Success, wrote ${outputArgs().outpath}")
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    Console.printLine("Done... ${Time/LocalTime.now()}");
    0