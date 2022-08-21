

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
    let* ans = PDTKit/Reader.readPdtFile(path);
    ans.leadSheet |> List.foreach(x -> println("${x.rowNumber}: ${x.titles}, ${x.description}, ${x.code}"));
    ans.datasheet.rows |> List.foreach(x -> println("${x.rowNumber}: ${x.fieldName} [${x.values}]"));
    Ok()
