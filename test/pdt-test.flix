use SheetIO/SheetParser.SheetParser;


def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    test01() |> println;
    test02() |> println;
    0


def test01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src = System/FilePath.new("G:/work/assets/product-data-templates/M82132_conveyor.xlsx");
    let* kvs = AssetLib/FileIO/PDT/XlsxReader.readFile("PDT_Conveyor", src);
    /// Map.foreach((k, v) -> Console.printLine("${k}: '${v}'"), kvs);
    Console.printLine("Map size: ${Map.size(kvs)}");
    Ok()


def test02(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    println("test02...");
    let src = System/FilePath.new("G:/work/assets/product-data-templates/M82132_conveyor.xlsx");
    let* ans = SheetIO/SheetParser.runXlsx(conveyorParser(), "PDT_Conveyor", (), src);    
    ans |> println;
    Ok()

def conveyorParser(): SheetParser[ka1, String] = 
    use SheetIO/SheetParser.{flatMap, return, row, skipRow, literal, content, skipManyTill, liftAction};
    use SheetIO/SheetParser.{*>};
    let* _      = liftAction(_ -> Console.printLine("conveyorParser.1"));
    let* s1     = row(literal("Asset Name") *> content());
    let* _      = liftAction(_ -> Console.printLine("conveyorParser.2"));
    let* s2     = row(literal("Asset Type") *> content());
    let* _      = liftAction(_ -> Console.printLine("conveyorParser.3"));
    let* _      = skipRow();
    let* _      = skipRow();
    let* _      = skipRow();
    let* _      = skipManyTill(skipRow(), row(literal("Dimension & Weight Data")));
    let* _      = liftAction(_ -> Console.printLine("conveyorParser.4"));
    let* s3     = row(literal("Overall length") *> content());
    let* _      = liftAction(_ -> Console.printLine("conveyorParser.5"));
    let* s4     = row(literal("Overall width") *> content());
    let* _      = skipManyTill(skipRow(), row(literal("Asset Data")));
    let* s5     = row(literal("Manufacturer's serial number") *> content());
    let* s6     = row(literal("Date of installation") *> content());
    let* s7     = row(literal("Tag reference") *> content());
    return(String.unlines(s1 :: s2 :: s3 :: s4 :: s5 :: s6 :: s7 :: Nil))
    


