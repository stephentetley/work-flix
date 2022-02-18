use RelLib/Lattice/Attributes.{Attributes};
use PDTKit/Aggregate/Schema.{AggregateRow, Tab};

pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    main01() |> println;
    0

def main01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src     = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-pdt.sqlite");
    let dst     = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-pdt-summary.xlsx");
    let* r1     = PDTKit/Aggregate/Loader.readAll(src);
    let relns   = r1 <+> PDTKit/Aggregate/Rules.makeAggregates();
    let* _      = PDTKit/Aggregate/ExcelOutput.outputExcel(relns, dst);    
    Ok()
