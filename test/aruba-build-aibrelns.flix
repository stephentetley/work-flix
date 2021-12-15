
use AssetLib/Aruba/Aib/Base.{AibFloc, AibEqui, AibSubFloc, AibEquiType};
use AssetLib/Aruba/Aib/Hierarchy.{Equipment, PlantItem, CommonNamePrefix, ChildFloc, MakeKey};

def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src         = 
        { path = System/FilePath.new("G:/work/assets/capital_schemes/lofts/lofts-worklist.xlsx")
        , sheet = "Equi" 
        };
    let* baseRep     = AssetLib/Aruba/Aib/Import/ExportFile.readExportRelations(src);

    /// println("Flocs...");
    /// query baseRep select (x1, x2, x3) from AibFloc(x1, x2, x3) |> Array.foreach(println);

    /// println("AibSubFloc...");
    /// query baseRep select (x1, x2) from AibSubFloc(x1, x2) |> Array.foreach(println);

    /*
    println("Equi...");
    /// let rename2 = xy -> (fst(xy), AssetLib/Base/Utils.properCaseName(snd(xy)));
    /// query baseRep select (x1, x2) from AibEqui(x1, x2) |> Array.foreach(rename2 >> println);

    
    /// query baseRep select (x1, x2) from SubFloc(x1, x2) |> Array.foreach(println);
    let tyrules = #{
        Type(name) :- AibEquiType(_, name).
    };
    println("Types used...");
    query baseRep <+> tyrules select x1 from Type(x1) |> Array.foreach(println);
    */

    let hrep = AssetLib/Aruba/Aib/Hierarchy.fromAibBaseRelations(baseRep);
    
    /// println("Equipment...");
    /// query hrep select (x1, x2, x3) from Equipment(x1, x2, x3) |> Array.foreach(println);
    
    println("PlantItem...");
    query hrep select (x1, x2, x3) from PlantItem(x1, x2, x3) |> Array.foreach(println);

    println("CommonNamePrefix...");
    query hrep select (x1; x2) from CommonNamePrefix(x1; x2) |> Array.foreach(println);

    println("ChildFloc...");
    query hrep select (x1, x2) from ChildFloc(x1, x2) |> Array.foreach(println);

    println("PreorderRow...");
    query hrep <+> AssetLib/Aruba/Aib/Hierarchy.preorderRows() select (x1, x2, x3, x4, x5) from PreorderRow(x1, x2, x3, x4, x5) 
        |> Array.foreach(println);

    AssetLib/Aruba/Aib/Hierarchy.toSaltTreeTable(hrep) |> println;

    Ok()  


    