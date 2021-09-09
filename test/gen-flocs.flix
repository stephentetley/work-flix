use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};

def programArgs(): UxlOutputArgs & Impure = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "New Flocs ${Time/LocalDate.now()}"
    , outpath = System/FilePath.new("G:/work/assets/cso-s4-migration/output/cso-site-flocs-UXL.xlsx")
    }


def main(_args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    let progArgs = programArgs();
    let workList = {path = System/FilePath.new("G:/work/assets/cso-s4-migration/gen-cso-site-flocs-worklist.xlsx"), sheet = "Sheet1"};
    let ans = AssetLib/GenS4/GenFlocs.emitFlocUxl(workList, progArgs);
    match ans {
        case Ok() => Console.printLine("Success, wrote ${progArgs.outpath}")
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    Console.printLine("Done... ${Time/LocalTime.now()}");
    0