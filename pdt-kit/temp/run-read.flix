

def main(): Unit \ IO = 
    println("Running...");
    match main1() {
        case Err(msg) => println(msg)
        case Ok()     => ()
    };
    ()

def main1(): Result[Unit, String] \ IO = 
    use Result.flatMap;
    let* path = Basis/System/FilePath.filePath("G:/work/assets/pdts/sample1.xlsx");
    let* ans = PDTKit/Reader.readPDT(path);
    ans |> List.foreach(x -> println("${x.rowNumber}: ${x.titles}, ${x.description}, ${x.code}"));
    Ok()
