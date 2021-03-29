

def main(_args: Array[String]): Int32 & Impure =
    Console.printLine("Running ${Time/LocalTime.now()}...");
    let src = System/FilePath.new("G:/work/assets/cost-centers/1stPass_Batch1.xlsx");
    let outputDir = System/FilePath.new("G:/work/assets/cost-centers/output");
    match CostCenters/Main.main1(src, outputDir, 1000) {
        case Ok() => {Console.printLine("Done"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }

    /// let outpath           = System/FilePath.new("G:/work/assets/cost-centers/sample-file-upload1.txt");
    /// let samples = 
    ///        {funcloc = "ROS12", costCenter = "178098", costCenterOrigin = Direct, description = "Rosenwell", statusOfObject = "OPER"}
    ///     :: {funcloc = "ROS12-WTN", costCenter = "", costCenterOrigin = Hierarchy, description = "Wastewater Transfer", statusOfObject = "OPER"}
    ///     :: Nil;
    /// match CostCenters/EmitFunclocTransferFile.outputFunclocFile("tetleys", samples, outpath) {
    ///     case Ok() => {Console.printLine("Done"); 0}
    ///     case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    /// }

/// def main1(src: System.FilePath): Result[Unit, String] & Impure = 
///     use Result.{flatMap};
///     let* xs = CostCenters/ReadDataSheet.readCostCentersFile(src);
///     let _ = Console.printLine("List length xs: ${List.length(xs)}");
///     let (ys, zs) = splitAt(10, xs);
///     let _ = Console.printLine("List length ys: ${List.length(ys)}");
///     let _ = Console.printLine("List length zs: ${List.length(zs)}");
///     let gs = groupsOf(1000, xs);
///     let _ = List.foreach(x1 -> Console.printLine("List length group: ${List.length(x1)}"), gs);
///     Ok()


/// pub def splitAt(n: Int32, xs: List[a]): (List[a], List[a]) = 
///     let k = (ys, zs) -> (ys, zs);
///     splitAtHelper(n, xs, k)

/// def splitAtHelper(n: Int32, xs: List[a], k: List[a] -> List[a] -> (List[a], List[a])): (List[a], List[a]) = 
///     if (n < 0)
///         k(Nil, xs)
///     else match xs { 
///         case x :: rs => if (n == 1) k(x :: Nil, rs) else splitAtHelper(n - 1, rs, (ys, zs) -> k(x :: ys, zs))
///         case Nil => k(Nil, Nil)
///     }
    

/// pub def groupsOf(n: Int32, xs: List[a]): List[List[a]] = groupsOfHelper(n, xs, ks -> ks)

/// def groupsOfHelper(n: Int32, xs: List[a], k: List[List[a]] -> List[List[a]]): List[List[a]] = 
///     match splitAt(n, xs) {
///         case (Nil,Nil) => k(Nil)
///         case (ys, Nil) => k(ys :: Nil)
///         case (ys, zs) => groupsOfHelper(n, zs, kss -> k(ys :: kss))
///     }

