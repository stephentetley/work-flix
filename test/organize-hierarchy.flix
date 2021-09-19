use Hierarchy/Organize.{BoosterPump, FinalEffPump, Organization};
   
def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use RelLib/RegexExtractor.{extract};
    let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/hudub/hudub-wwp-combined-worklist.xlsx"), 
                sheet="Equi_Worklist"};
    let* rows  = Hierarchy/Loader.loadExportRows(src);
    let relns = RelLib/Relation.foldMap(x1 -> extract(Hierarchy/Organize.getBoosterPump(), x1.commonName) 
                                                <+> extract(Hierarchy/Organize.getFinalEffPump(), x1.commonName) , rows);

    Hierarchy/Organize.organize(relns) 
        |> (ans1 -> query ans1 select (x1, x2, x3) from Organization(x1, x2, x3))
        |> RelLib/Tree.printAsTree3;

    Ok()  


