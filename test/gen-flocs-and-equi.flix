use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
use AssetLib/GenS4/GenUxl.{GenEquiArguments};

def outputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/1909_AIW_MOCR_Template.xlsx")
    , changeRequestName = "AMP 7 Leger Way"
    , outpath = System/FilePath.new("G:/work/assets/capital_schemes/leg01/output/1909_leger_way.xlsx")
    }

def equiArgs(): GenEquiArguments = 
    { aibEquipmentExport = 
        {path = System/FilePath.new("G:/work/assets/capital_schemes/leg01/leger-way-equipment-export.xlsx"), sheet = "Sheet1"}
    , aibMemosExport = 
        {path = System/FilePath.new("G:/work/assets/capital_schemes/leg01/leger-way-memos-export.xlsx"), sheet = "Sheet1"}
    , aibAgaspExport = 
        {path = System/FilePath.new("G:/work/assets/capital_schemes/leg01/leger-way-agasp-export.xlsx"), sheet = "Sheet1"}
    }


def main(_args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    let workBook = System/FilePath.new("G:/work/assets/capital_schemes/leg01/leger-way-worklist.xlsx");
    let flocWorkList = {path = workBook, sheet = "FlocWorkList"};
    let equiWorkList = {path = workBook, sheet = "EquiWorkList"};                        
    let ans = AssetLib/GenS4/GenUxl.generateCombinedUxl(flocWorkList, equiWorkList, equiArgs(), outputArgs());
    match ans {
        case Ok() => Console.printLine("Success, wrote ${outputArgs().outpath}")
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    Console.printLine("Done... ${Time/LocalTime.now()}");
    0