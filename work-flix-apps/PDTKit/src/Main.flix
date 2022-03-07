
/// TODO make this a proper `main` with GetOpt or JSON params etc.


def main(args: Array[String]): Int32 & Impure = 
    println("Running PDT Kit... ${Time/LocalTime.now()}");
    if (Array.length(args) >= 1) 
        match args[0] { 
            case "lint" => PDTKit/RunLint.runLint() |> println
            case "aggregate" => PDTKit/RunAggregate.runAggregate() |> println
            case _ => showHelp()
        }
    else
        showHelp();
    0

def showHelp(): Unit & Impure = 
    println("opts: lint ...")
