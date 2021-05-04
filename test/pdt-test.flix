


def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match test1() {
        case Ok() => 0
        case Err(msg) => {Console.printLine("Failed: ${msg}"); 1}
    }

def test1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src = System/FilePath.new("G:/work/assets/product-data-templates/M82132_conveyor.xlsx");
    let* kvs = AssetLib/FileIO/PDT/XlsxReader.readFile("PDT_Conveyor", src);
    Map.foreach((k, v) -> Console.printLine("${k}: '${v}'"), kvs);
    Console.printLine("Map size: ${Map.size(kvs)}");
    Ok()
