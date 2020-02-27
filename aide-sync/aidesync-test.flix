def checkLoaded(src: Result[reln, String]): reln = match src { 
    case Err(msg) => { Console.printLine(msg); #{ } }
    case Ok(rels) => rels
}

@test
def test01[r](): #{ AiRepeatedAttribute, AideRepeatedAttribute, RepeatedAttributeDiff | r } =
    let src1 = "G:\work\Projects\assets\aide_sync\CTE\KEV002\cte_ai_rep_attr_vals_structure.csv";
    let r1 = CsvLoader.importAiRepeatedAttributes(src1) |> checkLoaded;
    let src2 = "G:\work\Projects\assets\aide_sync\CTE\KEV002\cte_aide_rep_attr_vals_structure.csv";
    let r2 = CsvLoader.importAideRepeatedAttributes(src2) |> checkLoaded;
    solve r1 <+> r2 <+> AideSync.repeatedAttibuteDiff()


// This blows the heap - to investigate later...
@test
def testBomb01[r](): #{ AttributeDiff | r } =
    let src1 = "G:\work\Projects\assets\aide_sync\CTE\KEV002\cte_ai_attr_vals_structure.csv";
    let r1 = CsvLoader.importAiAttributes(src1) |> checkLoaded;
    let src2 = "G:\work\Projects\assets\aide_sync\CTE\KEV002\cte_aide_attr_vals_structure.csv";
    let r2 = CsvLoader.importAideAttributes(src2) |> checkLoaded;
    Console.printLine("Done read, solving...");
    project AttributeDiff (solve r1 <+> r2 <+> AideSync.attibuteDiff())


@test
def test02[r](): #{ AssetDiff, AssetNotInAide, AssetNotInAi | r } =
    let src1 = "G:\work\Projects\assets\aide_sync\CTE\KEV002\cte_ai_asset_structure.csv";
    let r1 = CsvLoader.importAiAssets(src1) |> checkLoaded;
    let src2 = "G:\work\Projects\assets\aide_sync\CTE\KEV002\cte_aide_asset_structure.csv";
    let r2 = CsvLoader.importAideAssets(src2) |> checkLoaded;
    Console.printLine("Done read, solving...");
    let ans1 = project AssetDiff (solve r1 <+> r2 <+> AideSync.assetDiff());
    let ans2 = project AssetNotInAide (solve r1 <+> r2 <+> AideSync.assetNotInAide());
    let ans3 = project AssetNotInAi (solve r1 <+> r2 <+> AideSync.assetNotInAi());
    ans1 <+> ans2 <+> ans3