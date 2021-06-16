use SheetIO/SheetParser.SheetParser;
use AssetLib/S4Lite/Datatypes.{UxlSource};

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    test01() |> println;
    0


def test01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src = System/FilePath.new("G:/work/assets/product-data-templates/M82132_conveyor.xlsx");
    let emitParams = 
        { uxlTemplate = System/FilePath.new("G:/work/assets/product-data-templates/MMOP uXL.xlsx")
        , changeRequestName = "PDT Sample"
        , outpath = System/FilePath.new("G:/work/assets/product-data-templates/pdt-output-uxl.xlsx")
        };
    let* uxlsrc = SheetIO/SheetParser.runXlsx(AssetLib/PDT/Products/Conveyor.parseConveyor("00001"), "PDT_Conveyor", (), src);    
    let* _ =  AssetLib/S4Lite/EmitUxl.outputUxl(emitParams, uxlsrc);
    Ok()



