use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};

def programArgs(): UxlOutputArgs & Impure = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "New Flocs ${Time/LocalDate.now()}"
    , outpath = System/FilePath.new("G:/work/assets/non-op-bins/output/nonop-added-flocs1-sites-UXL.xlsx")
    }


def main(_args: Array[String]): Int32 & Impure =  
    println("Running... ${Time/LocalTime.now()}");
    let progArgs = programArgs();
    let workList = {path = System/FilePath.new("G:/work/assets/non-op-bins/gen-site-flocs-worklist.xlsx"), sheet = "Sheet1"};
    let ans = AssetLib/GenS4/GenFlocs.emitFlocUxl(workList, progArgs);
    match ans {
        case Ok() => println("Success, wrote ${progArgs.outpath}")
        case Err(msg) => println("Error: ${msg}")
    };
    println("Done... ${Time/LocalTime.now()}");
    0