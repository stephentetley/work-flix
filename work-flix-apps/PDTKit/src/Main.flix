
/// TODO make this a proper `main` with GetOpt or JSON params etc.


def main(args: Array[String]): Int32 & Impure = 
    println("Running PDT Kit... ${Time/LocalTime.now()}");
    if (Array.length(args) >= 1) 
        match args[0] { 
            case "lint"      => PDTKit/RunLint.runLint(Array.dropLeft(1, args))
            case "aggregate" => PDTKit/RunAggregate.runAggregate(Array.dropLeft(1, args))
            case _           => {showHelp(); Ok(0)}
        } |> Result.getWithDefault(1)
    else
        showHelp();
    0



def showHelp(): Int32 & Impure = 
    println("opts: lint ...");
    0
