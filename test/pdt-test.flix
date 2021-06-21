use GetOpt.{ArgDescr, OptionDescr};
use GetOpt.ArgDescr.{NoArg, ReqArg, OptArg};

use SheetIO/SheetParser.SheetParser;
use AssetLib/S4Lite/Datatypes.{UxlSource};


pub def main(args: Array[String]): Int32 & Impure = 
    use GetOpt.ArgOrder.{Permute};
    use GetOpt.{getOpt, usageInfo};
    Console.printLine("Running... ${Time/LocalTime.now()}");
    let options1 = makeCmdLineOptions();
    let header = "Usage: <phase1> [OPTION...]";
    let args2 = GetOpt.preprocess({quoteOpen = "'", quoteClose = "'", stripQuoteMarks = true}, args);
    match getOpt(Permute, options1, args2) {
        case Failure(errs)  => {Console.printLine("Errors: ${errs}");  Console.printLine(usageInfo(header, options1)); 1}
        case Success(updates) => {
            let progArgs = List.foldLeft((ac, f) -> f(ac), defaultArguments(), updates.options);
            match test01(progArgs) {
                case Ok() => {Console.printLine("Wrote: ${progArgs.outputFile}"); 0}
                case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
            }
        }
    }


type alias ProgramArgs = 
    { inputFile: System.FilePath
    , outputFile: System.FilePath
    }

def defaultArguments(): ProgramArgs = 
    { inputFile = System/FilePath.new("")
    , outputFile =  System/FilePath.new("")
    }

type alias UpdateArguments = ProgramArgs -> ProgramArgs

def makeCmdLineOptions(): List[OptionDescr[UpdateArguments]] = 
      {optionIds = Nil,    optionNames = "input_file" :: Nil,     argDescriptor = ReqArg(setInputFile, "FILE"),                 explanation = "path to input file"}
   :: {optionIds = Nil,    optionNames = "output_file" :: Nil,      argDescriptor = ReqArg(setOutputFile, "FILE"),                 explanation = "output file"}
   :: Nil

def setInputFile(s: String): Option[UpdateArguments] = 
    Some(opts -> {inputFile = System/FilePath.new(s) | opts})

def setOutputFile(s: String): Option[UpdateArguments] = 
    Some(opts -> {outputFile = System/FilePath.new(s) | opts})


/// e.g "G:/work/assets/product-data-templates/M82132_conveyor.xlsx"
def test01(args: ProgramArgs): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src = args.inputFile;
    let emitParams = 
        { uxlTemplate = System/FilePath.new("G:/work/assets/product-data-templates/MMOP uXL.xlsx")
        , changeRequestName = "PDT Sample"
        , outpath = System/FilePath.new("G:/work/assets/product-data-templates/pdt-output-uxl.xlsx")
        };
    let* uxlsrc = SheetIO/SheetParser.runXlsx(AssetLib/PDT/Products/Conveyor.parseConveyor("00001"), "PDT_Conveyor", (), src);    
    let* _ =  AssetLib/S4Lite/EmitUxl.outputUxl(emitParams, uxlsrc);
    Ok()



