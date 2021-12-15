use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
use AssetLib/GenS4/GenUxl.{GenUxlSource};

def outputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/1909_AIW_MOCR_Template.xlsx")
    , changeRequestName = "R/1135/001 Beverley STW ## (WS) 27/10/21"
    , outpath = System/FilePath.new("G:/work/assets/capital_schemes/bever/output/bever_stw_uxl.xlsx")
    }

def sourceFiles(): GenUxlSource = 
    let workBook = System/FilePath.new("G:/work/assets/capital_schemes/bever/beverley-worklist2.xlsx");
    let opts = AssetLib/GenS4/GenUxl.emptyOptionalExports();
    { flocWorkList = Some({path = workBook, sheet = "Floc"})
    , equiWorkList = Some({path = workBook, sheet = "Equi"})
    , facts =
        { aibEquipmentExport = 
            {path = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-equipment-export.xlsx"), sheet = "Sheet1"}
        , aibMemosExport = 
            {path = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-memos-export.xlsx"), sheet = "Sheet1"}
        , aibAgaspExport = 
            {path = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-agasp-export.xlsx"), sheet = "Sheet1"}
        , optExports = 
            { aibElectricalExport =
                Some({path = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-electrical-export.xlsx"), sheet = "Sheet1"})
            , aibInstrumentExport =
                Some({path = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-instrument-export.xlsx"), sheet = "Sheet1"})
            , aibPumpExport = 
                Some({path = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-pump-export.xlsx"), sheet = "Sheet1"})
            , aibValveExport = 
                Some({path = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-valve-export.xlsx"), sheet = "Sheet1"})
            | opts}
        }
    }


def main(_args: Array[String]): Int32 & Impure =  
    println("Running... ${Time/LocalTime.now()}");                  
    let ans = AssetLib/GenS4/GenUxl.generateUxl(sourceFiles(), outputArgs());
    match ans {
        case Ok() => println("Success")
        case Err(msg) => println("Error: ${msg}")
    };
    println("Done... ${Time/LocalTime.now()}");
    0