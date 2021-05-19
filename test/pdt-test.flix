use AssetLib/FileIO/PDT.PDTParser;


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
    let src = System/FilePath.new("G:/work/assets/product-data-templates/M82132_conveyor.xlsx");
    let* ans = AssetLib/FileIO/PDT/PDTParser.parseFile(conveyorParser(), "PDT_Conveyor", src);
    ans |> println;
    Ok()

def conveyorParser(): PDTParser[String] = 
    use AssetLib/FileIO/PDT/PDTParser.{flatMap, return, evalRow, literal, content, skipRowsTill};
    use SheetIO/RowEvaluator.{*>};
    let* s1     = evalRow(literal(0, "Asset Name") *> content(1));
    let* s2     = evalRow(literal(0, "Asset Type") *> content(1));
    let* a1     = AssetLib/FileIO/PDT/PDTParser.getLastRowNum();
    let* _      = skipRowsTill(literal(0, "Dimension & Weight Data"));
    let* s3     = evalRow(literal(0, "Overall length") *> content(1));
    let* s4     = evalRow(literal(0, "Overall width") *> content(1));
    let* _      = skipRowsTill(literal(0, "Asset Data"));
    let* s5     = evalRow(literal(0, "Manufacturer's serial number") *> content(1));
    let* s6     = evalRow(literal(0, "Date of installation") *> content(1));
    let* s7     = evalRow(literal(0, "Tag reference") *> content(1));
    return(String.unlines("rows: ${a1}" :: s1 :: s2 :: s3 :: s4 :: s5 :: s6 :: s7 :: Nil))