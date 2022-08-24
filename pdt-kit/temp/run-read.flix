

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
    ans.leadSheet.attributes |> List.foreach(x -> println("${x.rowNum}: ${x.name}, ${x.value}, ${x.code}"));
    ans.dataDictionary.attributes |> List.foreach(x -> println("${x.rowNum}: ${x.category}::${x.name} / ${x.units}"));
    ans.dataSheet.multiAttributes |> List.foreach(x -> println("${x.rowNum}: ${x.name} [${x.values}]"));
    Ok()
