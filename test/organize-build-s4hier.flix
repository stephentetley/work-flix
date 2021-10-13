use AssetLib/AssetQuery/S4/IH06.{IH06Floc, IH06Equi};
use AssetLib/AssetQuery/Hiearachy.{Equipment, SubEquipment};

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06-all.txt");
    let* srcRel     = AssetLib/AssetQuery/S4/IH06.readHierarchyRelations(src);
    let hier        = AssetLib/AssetQuery/S4/IH06.buildHierarchy(srcRel);
    query hier select (x1, x2, x3) from Equipment(x1, x2, x3) |> Array.foreach(println);
    query hier select (x1, x2) from SubEquipment(x1, x2) |> Array.foreach(println);
    Ok()  


