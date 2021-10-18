use AssetLib/Aruba/Base.{FlocLevel, SubFloc};
   
def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
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


