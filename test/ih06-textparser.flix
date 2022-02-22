

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
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-ih06-structure-list.txt");
    let htmldest    = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-ih06.html");
    let jsondest    = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-ih06.json"); 
    let dbdest      = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-ih06.sqlite");   
    let* ast        = parseFileWithBOM(src);
    let _           = println("Count: " + Int32.toString(List.length(ast.rows))); 
    let* tree1      = buildIH06Tree(ast);
    let* _          = AssetLib/Base/ExportHtmlTree.writeHtmlTree(htmldest, toLabelledTree(tree1));
    let* _          = AssetLib/FileIO/S4/IH06Tree/ExportJson.exportJson(jsondest, tree1);
    let tableNames  = {flocTable = "ih06_flocs", equiTable = "ih06_equis"};
    let* _          = AssetLib/FileIO/S4/IH06Tree/SQLite.exportSQLite(tableNames, dbdest, ast);
    Ok()


