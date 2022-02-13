
pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    main01() |> println;
    0

def main01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src     = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-pdt.sqlite");
    let* r1     = PDTKit/Aggregate/Loader.readAll(src);
    let relns   = r1 <+> PDTKit/Aggregate/Rules.makeAggregates();
    query relns select (x1, x2, x3) from AggregateRow(x1, x2, x3; _) |> Array.foreach(println);
    Ok()

