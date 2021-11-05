use AssetLib/Aruba/Base.{S4FlocLevel, S4SubFloc};
use AssetLib/Aruba/S4Hierarchy.{Site, Function, ProcessGroup, Process, System, Subsystem, ChildFloc, ChildEqui, FunctionalLocation, PreorderRow};
   
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
    let* extra      = AssetLib/Aruba/S4/Import/IH08Table.readS4EquiTypes(src2);
    let db          = baseRep <+> extra;
    let rules       = #{
        /// These generate blanks in the tree and suggests we also need a "tree list" view...
        /// Organization(floc, "", "") :- 
        ///     FlocLevel(floc, 1).

        /// Organization(root, floc, "") :- 
        ///     FlocLevel(floc, 2), 
        ///     SubFloc(root, floc).

        Organization(root, parent1, floc) :- 
            S4FlocLevel(floc, 3), 
            S4SubFloc(parent1, floc),
            S4SubFloc(root, parent1).

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
    let hrep        = AssetLib/Aruba/S4/Hierarchy.fromS4BaseRelations(baseRep);
    let* extra      = AssetLib/Aruba/S4/Import/IH08Table.readS4EquiTypes(src2);
    let db          = hrep <+> extra;
    let rules       = #{

        /// These generate blanks in the tree and suggests we also need a "tree list" view...
        Organization(siteFloc, "", "", "", "") :- 
            Site(siteFloc, _).

        Organization(siteFloc, funFloc, "", "", "") :- 
            Function(funFloc, _),
            ChildFloc(siteFloc, funFloc).

        Organization(siteFloc, funFloc, pgFloc, "", "") :- 
            ProcessGroup(pgFloc, _), 
            ChildFloc(funFloc, pgFloc),
            ChildFloc(siteFloc, funFloc).

        Organization(siteFloc, funFloc, pgFloc, pFloc, "") :- 
            Process(pFloc, _), 
            ChildFloc(pgFloc, pFloc),
            ChildFloc(funFloc, pgFloc),
            ChildFloc(siteFloc, funFloc).

        Organization(siteFloc, funFloc, pgFloc, pFloc, sysFloc) :- 
            System(sysFloc, _), 
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
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/embsay/emb03-ih06-structure-list.txt");
    let src2        = {path = System/FilePath.new("G:/work/assets/capital_schemes/embsay/embsay-ih08.xlsx"),
                        sheet = "Sheet1"};
    let src3        = {path = System/FilePath.new("G:/work/assets/capital_schemes/embsay/embsay-ih06.xlsx"),
                        sheet = "Sheet1"};
    let* baseRep    = AssetLib/Aruba/S4/Import/IH06StructureList.readBaseRelations(src);
    let hrep        = AssetLib/Aruba/S4/Hierarchy.fromS4BaseRelations(baseRep);
    let* equitypes  = AssetLib/Aruba/S4/Import/IH08Table.readS4EquiTypes(src2);
    let* floctypes  = AssetLib/Aruba/S4/Import/IH06Table.readS4FlocTypes(src3);
    let db          = hrep <+> floctypes <+> equitypes;
    let rules       = #{

        /// Unbounded tree - including equipment at various levels and subequipment.
        Row3(item, (funcloc, name), parent) :- 
            PreorderRow(item, funcloc, parent),
            FunctionalLocation(funcloc, name).

        Row3(item, (equiId, name), parent) :-
            PreorderRow(item, equiId, parent),
            Equipment(equiId, name, _).

    } <+> AssetLib/Aruba/S4/Hierarchy.preorderRows();
    Console.printLine("Unbounded...");
    query db <+> rules select (x1, x2, x3) from Row3(x1, x2, x3) 
        /// |> RelLib/UnboundedTree.printAsTree("");
        |> Array.foreach(println);
    query db <+> rules select (x1, x2) from ChildEqui(x1, x2) 
            |> Array.foreach(println);

    AssetLib/Aruba/S4/ExportJson2.siteToJson(db) |> BasicJson/Pretty.renderJson |> println;        
    Ok()







