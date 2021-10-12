use AssetLib/AssetQuery/S4/IH06.{IH06Floc, IH06Equi};
   
def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src     = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06-all.txt");
    let* relns  = AssetLib/AssetQuery/S4/IH06.readHierarchyRelations(src);
    query relns select (x1, x2, x3) from IH06Floc(x1, x2, x3) |> Array.foreach(println);
    query relns select (x1, x2, x3, x4) from IH06Equi(x1, x2, x3, x4) |> Array.foreach(println);
    Ok()  


