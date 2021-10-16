use AssetLib/Aruba/S4/IH06.{IH06Floc, IH06Equi};
use AssetLib/Aruba/Base.{Floc, Equi};

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06-all.txt");
    let* srcRel     = AssetLib/Aruba/S4/IH06.readIH06Relations(src);
    let baseRep     = AssetLib/Aruba/S4/IH06.toBase(srcRel);
    query baseRep select (x1, x2) from Floc(x1, x2) |> Array.foreach(println);
    query baseRep select (x1, x2) from Equi(x1, x2) |> Array.foreach(println);
    Ok()  


