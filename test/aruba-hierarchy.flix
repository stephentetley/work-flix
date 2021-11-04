use AssetLib/Aruba/Base.{FlocLevel, SubFloc};
use AssetLib/Aruba/S4Hierarchy.{Site, Function, ProcessGroup, Process, System, Subsystem, ChildFloc, FunctionalLocation, PreorderRow};
   
def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    main2() |> println;
    main3() |> println;
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06-all.txt");
    let src2        = {path = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-equi-ih08.xlsx"),
                        sheet = "Sheet1"};
    let* baseRep    = AssetLib/Aruba/S4/Import/IH06StructureList.readBaseRelations(src);
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
    let* baseRep    = AssetLib/Aruba/S4/Import/IH06StructureList.readBaseRelations(src);
    let hrep        = AssetLib/Aruba/S4Hierarchy.fromS4BaseRelations(baseRep);
    let* extra      = AssetLib/Aruba/S4/IH08Table.readIH08Relations(src2);
    let db          = hrep <+> extra;
    let rules       = #{

        /// These generate blanks in the tree and suggests we also need a "tree list" view...
        Organization(siteFloc, "", "", "", "") :- 
            Site(siteFloc, _, _).

        Organization(siteFloc, funFloc, "", "", "") :- 
            Function(funFloc, _, _),
            ChildFloc(siteFloc, funFloc).

        Organization(siteFloc, funFloc, pgFloc, "", "") :- 
            ProcessGroup(pgFloc, _, _), 
            ChildFloc(funFloc, pgFloc),
            ChildFloc(siteFloc, funFloc).

        Organization(siteFloc, funFloc, pgFloc, pFloc, "") :- 
            Process(pFloc, _, _), 
            ChildFloc(pgFloc, pFloc),
            ChildFloc(funFloc, pgFloc),
            ChildFloc(siteFloc, funFloc).

        Organization(siteFloc, funFloc, pgFloc, pFloc, sysFloc) :- 
            System(sysFloc, _, _), 
            ChildFloc(pFloc, sysFloc),
            ChildFloc(pgFloc, pFloc),
            ChildFloc(funFloc, pgFloc),
            ChildFloc(siteFloc, funFloc).

    };
    /// query db <+> rules select (x1, x2, x3, x4) from Organization(x1, x2, x3, x4) |> Array.foreach(println);
    query db <+> rules select (x1, x2, x3, x4, x5) from Organization(x1, x2, x3, x4, x5) 
        |> Array.map(RelLib/Tree2.path5)
        |> RelLib/Tree2.buildTree 
        |> Result.map(PlantUml/SaltTree.tree({printLabel = PlantUml/Creole.text}))
        |> Result.map(PlantUml/Puml.render)
        |> println;
    Ok()

def main3(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06-all.txt");
    let src2        = {path = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-equi-ih08.xlsx"),
                        sheet = "Sheet1"};
    let* baseRep    = AssetLib/Aruba/S4/Import/IH06StructureList.readBaseRelations(src);
    let hrep        = AssetLib/Aruba/S4Hierarchy.fromS4BaseRelations(baseRep);
    let* extra      = AssetLib/Aruba/S4/IH08Table.readIH08Relations(src2);
    let db          = hrep <+> extra;
    let rules       = #{

        /// Unbounded tree - including equipment at various levels and subequipment.
        Row3(item, (flocId, name), parent) :- 
            PreorderRow(item, flocId, parent),
            FunctionalLocation(flocId, name).

        Row3(item, (equiId, name), parent) :-
            PreorderRow(item, equiId, parent),
            Equipment(equiId, name, _).

    } <+> AssetLib/Aruba/S4Hierarchy.functionalLocations() <+> AssetLib/Aruba/S4Hierarchy.preorderRows();
    Console.printLine("Unbounded...");
    query db <+> rules select (x1, x2, x3) from Row3(x1, x2, x3) 
        |> RelLib/UnboundedTree.printAsTree("");
    Ok()







