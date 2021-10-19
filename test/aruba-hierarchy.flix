use AssetLib/Aruba/Base.{FlocLevel, SubFloc};
use AssetLib/Aruba/S4Hierarchy.{Site, Function, ChildFloc};
   
def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    main2() |> println;
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06-all.txt");
    let src2        = {path = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-equi-ih08.xlsx"),
                        sheet = "Sheet1"};
    let* srcRel     = AssetLib/Aruba/S4/IH06Tree.readIH06Relations(src);
    let baseRep     = AssetLib/Aruba/S4/IH06Tree.toBase(srcRel);
    let* extra      = AssetLib/Aruba/S4/IH08Table.readIH08Relations(src2);
    let db          = baseRep <+> extra;
    let rules       = #{
        /// These generate blanks in the tree and suggests we also need a "tree list" view...
        /// Organization(floc, "", "") :- 
        ///     FlocLevel(floc, 1).

        /// Organization(root, floc, "") :- 
        ///     FlocLevel(floc, 2), 
        ///     SubFloc(root, floc).

        Organization(root, parent1, floc) :- 
            FlocLevel(floc, 3), 
            SubFloc(parent1, floc),
            SubFloc(root, parent1).

    };
    query db <+> rules select (x1, x2, x3) from Organization(x1, x2, x3) |> Array.foreach(println);
    query db <+> rules select (x1, x2, x3) from Organization(x1, x2, x3) |> RelLib/Tree.printAsTree3;
    Ok()

def main2(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06-all.txt");
    let src2        = {path = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-equi-ih08.xlsx"),
                        sheet = "Sheet1"};
    let* srcRel     = AssetLib/Aruba/S4/IH06Tree.readIH06Relations(src);
    let baseRep     = AssetLib/Aruba/S4/IH06Tree.toBase(srcRel);
    let hrep        = AssetLib/Aruba/S4Hierarchy.fromS4BaseRelations(baseRep);
    let* extra      = AssetLib/Aruba/S4/IH08Table.readIH08Relations(src2);
    let db          = hrep <+> extra;
    let rules       = #{

        /// These generate blanks in the tree and suggests we also need a "tree list" view...
        Organization(flocId, "", "", "") :- 
            Site(flocId, _, _).

        Organization(siteFid, flocId, "", "") :- 
            Function(flocId, _, _),
            ChildFloc(siteFid, flocId).

        Organization(siteFid, funFid, flocId, "") :- 
            ProcessGroup(flocId, _, _), 
            ChildFloc(funFid, flocId),
            ChildFloc(siteFid, funFid).

        Organization(siteFid, funFid, pgFid, flocId) :- 
            Process(flocId, _, _), 
            ChildFloc(pgFid, flocId),
            ChildFloc(funFid, pgFid),
            ChildFloc(siteFid, funFid).

    };
    query db <+> rules select (x1, x2, x3, x4) from Organization(x1, x2, x3, x4) |> Array.foreach(println);
    /// query db <+> rules select (x1, x2, x3) from Organization(x1, x2, x3) |> RelLib/Tree.printAsTree3;
    Ok()




