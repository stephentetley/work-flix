use RelLib/Lattice/Attributes.{Attributes};
use PDTKit/Aggregate/Schema.{AggregateRow, Tab};

pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    main01() |> println;
    0

def main01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src     = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-pdt.sqlite");
    let* r1     = PDTKit/Aggregate/Loader.readAll(src);
    let relns   = r1 <+> PDTKit/Aggregate/Rules.makeAggregates();
    relns |> PDTKit/Aggregate/ExcelOutput.makeHeaders |> println;
    /// query relns select (x1, x2, x3; x4) from AggregateRow(x1, x2, x3; x4) |> Array.foreach(println);
    Ok()

/// def collapse(x: (String, String, String, Attributes[String, String])): (String, String, String, String) = 
///     let (x1, x2, x3, x4) = x;
///     (x1, x2, x3, ToString.toString(x4))