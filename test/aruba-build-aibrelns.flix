
use AssetLib/Aruba/Aib/Base.{AibFloc, AibEqui, AibSubFloc, AibEquiType};
use AssetLib/Aruba/Aib/Hierarchy.{S4EquiType, PreorderRow};

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src         = 
        { path = System/FilePath.new("G:/work/assets/capital_schemes/lofts/lofts-worklist.xlsx")
        , sheet = "Equi" 
        };
    let* srcRel     = AssetLib/Aruba/Aib/Import/ExportFile.readExportRelations(src);
    let baseRep     = AssetLib/Aruba/Aib/Import/ExportFile.toBase(srcRel);
    Console.printLine("Flocs...");
    query baseRep select (x1, x2, x3) from AibFloc(x1, x2, x3) |> Array.foreach(println);

    Console.printLine("AibSubFloc...");
    query baseRep select (x1, x2) from AibSubFloc(x1, x2) |> Array.foreach(println);
    /*
    Console.printLine("Equi...");
    /// let rename2 = xy -> (fst(xy), AssetLib/Base/Utils.properCaseName(snd(xy)));
    /// query baseRep select (x1, x2) from AibEqui(x1, x2) |> Array.foreach(rename2 >> println);

    
    /// query baseRep select (x1, x2) from SubFloc(x1, x2) |> Array.foreach(println);
    let tyrules = #{
        Type(name) :- AibEquiType(_, name).
    };
    Console.printLine("Types used...");
    query baseRep <+> tyrules select x1 from Type(x1) |> Array.foreach(println);
    */
    let hrep = AssetLib/Aruba/Aib/Hierarchy.fromAibBaseRelations(baseRep);
    
    Console.printLine("PreorderRow...");
    query hrep <+> AssetLib/Aruba/Aib/Hierarchy.preorderRows() select (x1, x2, x3, x4, x5) from PreorderRow(x1, x2, x3, x4, x5) 
        |> Array.foreach(println);

    (hrep <+> AssetLib/Aruba/Aib/Hierarchy.preorderRows()) 
        |> AssetLib/Aruba/Aib/Hierarchy.toSaltTreeTable 
        |> Console.printLine;
    Ok()  
