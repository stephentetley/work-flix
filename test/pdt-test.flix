use SheetIO/SheetParser.SheetParser;


def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    test01() |> println;
    0


def test01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src = System/FilePath.new("G:/work/assets/product-data-templates/M82132_conveyor.xlsx");
    let* ans = SheetIO/SheetParser.runXlsx(conveyorParser(), "PDT_Conveyor", (), src);    
    ans |> println;
    Ok()

def conveyorParser(): SheetParser[ka1, String] = 
    use SheetIO/SheetParser.{flatMap, return, row, skipRow, literal, content, find, bounded, liftAction, gotoRow};
    use SheetIO/SheetParser.{*>};
    let* a1     = PDT/Common.parseProductData(PDT/Conveyor.parseConveyorData());
    return(String.unlines(a1.common.assetName  :: a1.common.specificModel :: a1.common.serialNumber :: "${a1.common.dateOfInstallation}" :: Nil))
    
