use AssetLib/Aruba/S4/IH06.{IH06Floc, IH06Equi};
use AssetLib/Aruba/Base.{AibFloc, AibEqui, AibSubFloc, AibEquiType};

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let rename2 = xy -> (fst(xy), AssetLib/Base/Utils.properCaseName(snd(xy)));
    let src         = 
        { path = System/FilePath.new("G:/work/assets/capital_schemes/bever/beverley-worklist2.xlsx")
        , sheet = "Equi" 
        };
    let* srcRel     = AssetLib/Aruba/Aib/Import/ExportFile.readExportRelations(src);
    let baseRep     = AssetLib/Aruba/Aib/Import/ExportFile.toBase(srcRel);
    Console.printLine("Flocs...");
    query baseRep select (x1, x2, x3) from AibFloc(x1, x2, x3) |> Array.foreach(println);
    Console.printLine("Equi...");
    query baseRep select (x1, x2) from AibEqui(x1, x2) |> Array.foreach(rename2 >> println);
    /// query baseRep select (x1, x2) from SubFloc(x1, x2) |> Array.foreach(println);
    let tyrules = #{
        Type(name) :- AibEquiType(_, name).
    };
    Console.printLine("Types used...");
    query baseRep <+> tyrules select x1 from Type(x1) |> Array.foreach(println);
    Ok()  
