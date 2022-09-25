use Applicative.{*>};
use PDTKit/PdtL/Datatypes.{PdtFile};

def main(): Unit \ IO = 
    println("Running...");
    match main1() {
        case Err(msg) => println(msg)
        case Ok()     => ()
    };
    ()

def main1(): Result[Unit, String] \ IO = 
    use Result.flatMap;
    let* path = Basis/System/Path.newPath("G:/work/assets/pdts/sample1.xlsx");
    let* ans = PDTKit/PdtL/ReadPdt.readPdtFile(path);
    ans.leadSheet.attributes |> List.foreach(x -> println("ans.leadSheet.attributes: ${x.rowNum}: ${x.name}, ${x.value}, ${x.code}"));
    ans.dataDictionary.attributes |> List.foreach(x -> println("${x.rowNum}: ${x.category}::${x.name} / ${x.units}"));
    ans.dataSheet.multiAttributes |> List.foreach(x -> println("${x.rowNum}: ${x.name} [${x.values}]"));
    ans.leadSheet.headings |> List.foreach(x -> println("ans.leadSheet.heading: ${x.rowNum}: ${x.heading}"));
    printJson(ans);
    Ok()

def printJson(pdtL: PdtFile): Unit \ IO =
    region r {
        let proc = () -> PDTKit/PdtL/WriteJson.buildJson(pdtL);
        Basis/Json/JsonObjectBuilder.build(r, proc()) |> println;
        ()
    }
