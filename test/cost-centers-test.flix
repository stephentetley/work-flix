
use CostCenters/EmitFunclocTransferFile.Origin.{Direct, Hierarchy};

def main(_args: Array[String]): Int32 & Impure =
    Console.printLine("Running...");
    let outpath           = System/FilePath.new("G:/work/assets/cost-centers/sample-file-upload1.txt");
    let samples = 
           {funcloc = "ROS12", costCenter = "178098", costCenterOrigin = Direct, description = "Rosenwell", statusOfObject = "OPER"}
        :: {funcloc = "ROS12-WTN", costCenter = "", costCenterOrigin = Hierarchy, description = "Wastewater Transfer", statusOfObject = "OPER"}
        :: Nil;
    match CostCenters/EmitFunclocTransferFile.outputFunclocFile("tetleys", samples, outpath) {
        case Ok() => {Console.printLine("Done"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }