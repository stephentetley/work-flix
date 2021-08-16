use SheetIO/Reader.XlsxSource;

type alias ProgramArgs = 
    { inputSource: XlsxSource
    , outputFile: System.FilePath
    }


pub def main(_args: Array[String]): Int32 & Impure = 
    let args = {inputSource = { path = System/FilePath.new("G:/work/assets/product-data-templates/TEST-STA-WWT-ASP-PI-B-0002-Pumps.xlsx"),
                            sheet = "Pumps"},
                outputFile = System/FilePath.new("G:/work/assets/product-data-templates/cadpi-pumps-output1.xlsx")};
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match test01(args) {
        case Ok() => {Console.printLine("Wrote: ${args.outputFile}"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }

/// e.g "G:/work/assets/product-data-templates/M82132_conveyor.xlsx"
def test01(args: ProgramArgs): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let emitParams = 
        { uxlTemplate = System/FilePath.new("G:/work/assets/product-data-templates/MMOP uXL.xlsx")
        , changeRequestName = "P and I Pump Extract Sample"
        , outpath = args.outputFile
        };
    let* worklist   = AssetLib/ProductData/AC/Products/Pump.loadPumpRows(args.inputSource);    
    
    worklist |> List.foreach(x1 -> Console.printLine("${x1.description} ${x1.className} [${x1.manufacturer}]"));
    /// let* _      =  AssetLib/S4Lite/EmitUxl.outputUxl(true, emitParams, uxlsrc);

    let* uxl        = AssetLib/GenS4/GenEquiMonad.execGenEquiMonad(AssetLib/ProductData/AC/Products/Pump.genPumps(worklist));
    let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(false, emitParams, uxl);
    Ok()



