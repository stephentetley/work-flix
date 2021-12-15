

use AssetLib/FileIO/S4/IH06Tree/Parser.{parseFileWithBOM};
use AssetLib/FileIO/S4/IH06Tree/Builder.{buildIH06Tree, toLabelledTree};
    


def main(_args: Array[String]): Int32 & Impure =
    println("Running... ${Time/LocalTime.now()}");
    match main1() { 
        case Ok() => {println("Okay"); 0}
        case Err(msg) => {println("Error: ${msg}"); 1}
    }

def main1(): Result[Unit, String] & Impure =
    use Result.flatMap;
    use AssetLib/Base/ExportHtmlTree.{writeHtmlTree};
    use AssetLib/FileIO/S4/IH06Tree/ExportJson.{exportJson};
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06-all.txt");
    let htmldest    = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06.html");
    let jsondest    = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06.json");   
    let* ast        = parseFileWithBOM(src);
    let _           = println("Count: " + Int32.toString(List.length(ast.rows))); 
    let* tree1      = buildIH06Tree(ast);
    let* _          = writeHtmlTree(htmldest, toLabelledTree(tree1));
    let* _          = exportJson(jsondest, tree1);
    Ok()


