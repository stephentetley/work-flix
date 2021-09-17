use Hierarchy/Organize.{BoosterPump, FinalEffPump, Floc};
   
def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use Hierarchy/Organize.{extractFromCommonName};
    let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-wwp-combined-worklist.xlsx"), 
                sheet="Equi_Worklist"};
    let* rows  = Hierarchy/Loader.loadExportRows(src);
    /// let relns = RelLib/Relation.foldMap(x1 -> extractFromCommonName(Hierarchy/Organize.getBoosterPump(), x1.commonName) 
    ///                                             <+> extractFromCommonName(Hierarchy/Organize.getFinalEffPump(), x1.commonName) , rows);
    /// query relns select (x1, x2, x3) from BoosterPump(x1, x2, x3) |> Array.foreach(println);
    /// query relns select (x1, x2) from FinalEffPump(x1, x2) |> Array.foreach(println);

    /// Hierarchy/Organize.organize("HUDUB-SSS-SWS-SWR", relns) 
    ///     |> (ans1 -> query ans1 select (x1, x2, x3) from Floc(x1, x2, x3))
    ///     |> Array.map(RelLib/Tuple.decons3((_, x2, x3) -> (x2, x3)))
    ///     |> RelLib/Tree.printAsTree2;
    ///     /// |> Array.foreach(println);
    let names = List.filterMap(x1 -> Hierarchy/Organize.extractFromCommonName2(Hierarchy/Organize.getEquipmentName(), x1.commonName), rows);
    
    List.foreach(println, names);
    Ok()  

/// def test01(): Unit & Impure = 
///     let patt = 
///         /// match Text/Regex/Pattern.compile("\\p{Space}+|\\-|/") {
///         match Text/Regex/Pattern.compile(";") {
///             case Ok(p1) => p1
///             case Err(msg) => bug!(msg)
///     };
///     Text/Regex.indexOfLeft(patt, "NO;2 DRUM THICKENER WASHWATER PUMP/PIPEWORK AND FITTINGS") |> println;
///     Text/Regex.breakOnLeft(patt, "NO;2 DRUM THICKENER WASHWATER PUMP/PIPEWORK AND FITTINGS") |> println;
///     ()
