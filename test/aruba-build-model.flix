
def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    test01() |> println;
    0


def test01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let _ = Console.printLine("Build model...");
    let src = 
        { ih06Text = System/FilePath.new("G:/work/assets/asset_models/grain-ih06.txt")
        , ih06Table = System/FilePath.new("G:/work/assets/asset_models/grain-ih06-export.xlsx")
        , ih08Table = System/FilePath.new("G:/work/assets/asset_models/grain-ih08-export.xlsx")
        };
    let* ast        = AssetLib/Aruba/S4/Builder.buildGSSite(src);
    let _           = Console.printLine("funcount: ${List.length(ast.functions)}");
    let jsonDest    = System/FilePath.new("G:/work/assets/asset_models/grain-output.json");
    let* _          = AssetLib/Aruba/S4/ExportJson.exportJson(jsonDest, ast);
    Ok()