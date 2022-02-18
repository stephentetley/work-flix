use RelLib/Lattice/Attributes.{Attributes};
use PDTKit/Aggregate/Schema.{AggregateRow, Tab};

pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    main01() |> println;
    0

def main01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let _src     = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-pdt.sqlite");
    let _dst     = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-pdt-lint.xlsx");
    println("TODO");
    Ok()
