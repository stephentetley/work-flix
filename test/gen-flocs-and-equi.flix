use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
use AssetLib/GenS4/GenUxl.{GenUxlSource};

def outputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/1909_AIW_MOCR_Template.xlsx")
    , changeRequestName = "R/1238/001 Embsay STW Ferric (BF) 14/09/21"
    , outpath = System/FilePath.new("G:/work/assets/capital_schemes/embsay/output/embsay_stw_ferric_uxl.xlsx")
    }

def sourceFiles(): GenUxlSource = 
    let workBook = System/FilePath.new("G:/work/assets/capital_schemes/embsay/embsay-stw-ferric-worklist.xlsx");
    let opts = AssetLib/GenS4/GenUxl.emptyOptionalExports();
    { flocWorkList = Some({path = workBook, sheet = "Floc"})
    , equiWorkList = Some({path = workBook, sheet = "Equi"})
    , facts =
        { aibEquipmentExport = 
            {path = System/FilePath.new("G:/work/assets/capital_schemes/embsay/embsay-equipment-export.xlsx"), sheet = "Sheet1"}
        , aibMemosExport = 
            {path = System/FilePath.new("G:/work/assets/capital_schemes/embsay/embsay-memos-export.xlsx"), sheet = "Sheet1"}
        , aibAgaspExport = 
            {path = System/FilePath.new("G:/work/assets/capital_schemes/embsay/embsay-agasp-export.xlsx"), sheet = "Sheet1"}
        }
    , optionalFacts = 
        { aibElectricalExport =
            Some({path = System/FilePath.new("G:/work/assets/capital_schemes/embsay/embsay-electrical-export.xlsx"), sheet = "Sheet1"})
        , aibInstrumentExport =
            Some({path = System/FilePath.new("G:/work/assets/capital_schemes/embsay/embsay-instrument-export.xlsx"), sheet = "Sheet1"})
        , aibPumpExport = 
            Some({path = System/FilePath.new("G:/work/assets/capital_schemes/embsay/embsay-pump-export.xlsx"), sheet = "Sheet1"})
        , aibValveExport = 
            Some({path = System/FilePath.new("G:/work/assets/capital_schemes/embsay/embsay-valve-export.xlsx"), sheet = "Sheet1"})
        | opts}
    }


def main(_args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");                  
    let ans = AssetLib/GenS4/GenUxl.generateUxl(sourceFiles(), outputArgs());
    match ans {
        case Ok() => Console.printLine("Success")
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    Console.printLine("Done... ${Time/LocalTime.now()}");
    0