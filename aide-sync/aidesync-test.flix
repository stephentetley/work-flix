def checkLoaded(src: Result[reln, String]): reln & Impure = match src { 
    case Err(msg) => { Console.printLine(msg); #{ } }
    case Ok(rels) => rels
}


// This may throw error - TODO test files exist...
@test
def test01[r](): #{ AiRepeatedAttribute, AideRepeatedAttribute, RepeatedAttributeDiff | r } & Impure =
    let src1 = "G:\work\Projects\assets\aide_sync\CTE\KEV002\cte_ai_rep_attr_vals_structure.csv";
    let r1 = CsvLoader.importCteAiRepeatedAttributes(src1) |> checkLoaded;
    let src2 = "G:\work\Projects\assets\aide_sync\CTE\KEV002\cte_aide_rep_attr_vals_structure.csv";
    let r2 = CsvLoader.importCteAideRepeatedAttributes(src2) |> checkLoaded;
    solve r1 <+> r2 <+> AideSync.repeatedAttibuteDiff()


// This blows the heap if we have multiple schemes...
@test
def test02[r](): #{ AttributeDiff | r } & Impure =
    let src1 = "G:\work\Projects\assets\aide_sync\CTE\KEV002\cte_ai_attr_vals_structure.csv";
    let r1 = CsvLoader.importCteAiAttributes(src1) |> checkLoaded;
    let src2 = "G:\work\Projects\assets\aide_sync\CTE\KEV002\cte_aide_attr_vals_structure.csv";
    let r2 = CsvLoader.importCteAideAttributes(src2) |> checkLoaded;
    Console.printLine("Done read, solving...");
    project AttributeDiff (solve r1 <+> r2 <+> AideSync.attibuteDiff())


@test
def test03[r](): #{ AssetDiff, AssetNotInAide, AssetNotInAi | r } & Impure =
    let src1 = "G:\work\Projects\assets\aide_sync\CTE\KEV002\cte_ai_asset_structure.csv";
    let r1 = CsvLoader.importCteAiAssets(src1) |> checkLoaded;
    let src2 = "G:\work\Projects\assets\aide_sync\CTE\KEV002\cte_aide_asset_structure.csv";
    let r2 = CsvLoader.importCteAideAssets(src2) |> checkLoaded;
    Console.printLine("Done read, solving...");
    let ans1 = project AssetDiff (solve r1 <+> r2 <+> AideSync.assetDiff());
    let ans2 = project AssetNotInAide (solve r1 <+> r2 <+> AideSync.assetNotInAide());
    let ans3 = project AssetNotInAi (solve r1 <+> r2 <+> AideSync.assetNotInAi());
    ans1 <+> ans2 <+> ans3

