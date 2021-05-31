use AssetLib/GenS4/GenFlocs.{GenFlocsArguments};

def programArgs(): GenFlocsArguments & Impure = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , flocWorkList = {file = System/FilePath.new("G:/work/assets/genflocs/worklist1.xlsx"), sheet = "Sheet1"}
    , changeRequestName = "New Flocs ${Time/LocalDate.now()}"
    , outpath = System/FilePath.new("G:/work/assets/genflocs/uxl-output1.xlsx")
    }


def main(_args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    let progArgs = programArgs();
    let ans = AssetLib/GenS4/GenFlocs.genFlocs(progArgs);
    match ans {
        case Ok() => Console.printLine("Success, wrote ${progArgs.outpath}")
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    Console.printLine("Done... ${Time/LocalTime.now()}");
    0