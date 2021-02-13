

def main(_ars: Array[String]): Int32 & Impure = 
    Console.printLine("Running...");
    let src = System/FilePath.new("G:/work/assets/skeleton/skeleton1.xlsx");
    match Skeleton/XlsxReader.readAnnotatedAibExport(src) { 
        case Ok(xs) => List.foreach(x -> Console.printLine("${x.reference} ${x.installedFrom}"), xs)
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    0


