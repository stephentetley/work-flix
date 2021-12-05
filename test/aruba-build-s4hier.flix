
use AssetLib/Aruba/S4/Base.{S4Floc, S4Equi};
use AssetLib/Aruba/S4/Hierarchy.{S4EquiType, PreorderRow};

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06-all.txt");
    let src2        = {path = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-equi-ih08.xlsx"),
                        sheet = "Sheet1"};
    let* srcRel     = AssetLib/Aruba/S4/Import/IH06StructureList.readIH06Relations(src);
    let baseRep     = AssetLib/Aruba/S4/Import/IH06StructureList.toBase(srcRel);
    let* tyinfo     = AssetLib/Aruba/S4/Import/IH08Table.readS4EquiTypes(src2);
    let db          = baseRep <+> tyinfo;    
    query db select (x1, x2) from S4Floc(x1, x2) |> Array.foreach(println);
    query db select (x1, x2) from S4Equi(x1, x2) |> Array.foreach(println);
    let tyrules = #{
        Type(name) :- S4EquiType(_, name).
    };
    query db <+> tyrules select x1 from Type(x1) |> Array.foreach(println);

    let hrep = AssetLib/Aruba/S4/Hierarchy.fromS4BaseRelations(db);
    
    query hrep <+> AssetLib/Aruba/S4/Hierarchy.preorderRows() select x1 from PreorderRow(x1, _, _, _, _) |> Array.foreach(println);

    Ok()
