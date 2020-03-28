
pub def treeSrc() : Str = "G:\work\Projects\assets\langs_data\LANGS_funcloc_tree.txt"


@test 
def readTree01(): Unit & Impure = 
    let path = Path.new(treeSrc());
    match Path.readLines(path) {
        case Err(_) => Console.printLine("io error")
        case Ok(xs) => List.foreach(x -> Console.printLine(x), xs)
    }
        

@test 
def readTree02(): Unit & Impure  = 
    let path = Path.new(treeSrc());
    match FlocReport/Base.foldLines(_ -> TextParser.restOfInput(), "", path) {
        case Err(_) => Console.printLine("io error")
        case Ok(lastline) => Console.printLine(lastline)
    }

@test 
def main01(): Result[Unit, String] & Impure = 
    let dest = "G:\work\Projects\assets\langs_data\output1.csv";
    FlocReport.generateReport(treeSrc(), dest)
