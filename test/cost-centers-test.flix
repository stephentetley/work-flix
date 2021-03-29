
use CostCenters/EmitFunclocTransferFile.Origin.{Direct, Hierarchy};

def main(_args: Array[String]): Int32 & Impure =
    Console.printLine("Running ${Time/LocalTime.now()}...");
    main1()

    /// let outpath           = System/FilePath.new("G:/work/assets/cost-centers/sample-file-upload1.txt");
    /// let samples = 
    ///        {funcloc = "ROS12", costCenter = "178098", costCenterOrigin = Direct, description = "Rosenwell", statusOfObject = "OPER"}
    ///     :: {funcloc = "ROS12-WTN", costCenter = "", costCenterOrigin = Hierarchy, description = "Wastewater Transfer", statusOfObject = "OPER"}
    ///     :: Nil;
    /// match CostCenters/EmitFunclocTransferFile.outputFunclocFile("tetleys", samples, outpath) {
    ///     case Ok() => {Console.printLine("Done"); 0}
    ///     case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    /// }

def main1(): Int32 & Impure =
    use CostCenters/SetupDb.{storeCostCenters};
    let dbPath  = System/FilePath.new("G:/work/assets/cost-centers/cost_centers.sqlite");
    let xlsxPath  = System/FilePath.new("G:/work/assets/cost-centers/FLOC Upload 26 03.xlsx");
    
    match BasicDb/DbMonad.runSQLite(storeCostCenters(xlsxPath), dbPath) {
        case Ok() => {Console.printLine("Done"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }