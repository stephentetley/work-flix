

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
    let* ans = PDTKit/Internal/Reader.readPdtFile(path);
    ans.leadSheet |> List.foreach(x -> println("${x.rowNum}: ${x.titles}, ${x.description}, ${x.code}"));
    ans.dataDictionary |> List.foreach(x -> println("${x.rowNum}: ${x.paramName} / ${x.units}"));
    ans.datasheet.rows |> List.foreach(x -> println("${x.rowNum}: ${x.fieldName} [${x.values}] ${x.size}"));
    Ok()
