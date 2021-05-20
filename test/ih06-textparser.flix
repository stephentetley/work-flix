

use AssetLib/FileIO/S4/IH06Tree/Parser.{parseFileWithBOM};
use AssetLib/FileIO/S4/IH06Tree/Builder.{buildIH06Trees, allLabelledTrees};
use AssetLib/FileIO/S4/IH06Tree/ExportCsv.{CsvOutputPaths, exportCsv};
use AssetLib/FileIO/S4/IH06Tree/ExportDb.{defaultTableNames, storeIH06Trees};
    

def csvDest(): CsvOutputPaths = 
    { flocOutpath = System/FilePath.new("G:/work/assets/capital_schemes/wethe-ih06-flocs.csv")
    , equiOutpath = System/FilePath.new("G:/work/assets/capital_schemes/wethe-ih06-equis.csv")
    }

def main(_args: Array[String]): Int32 & Impure =
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match main1() { 
        case Ok() => {Console.printLine("Okay"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }

def main1(): Result[Unit, String] & Impure =
    use Result.flatMap;
    use AssetLib/Base/ExportHtmlTree.{writeHtmlForest};
    use AssetLib/FileIO/S4/IH06Tree/ExportJson.{exportJson};
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06-all.txt");
    let htmldest    = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06.html");
    let dbdest      = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06.sqlite");
    let jsondest    = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06.json");
    let* _          = exportCsv(src, Text/Charset.utf_8(), true, csvDest());    
    let* ast        = parseFileWithBOM(src);
    let _           = Console.printLine("Count: " + Int32.toString(List.length(ast.rows))); 
    let trees       = buildIH06Trees(ast);
    let* _          = writeHtmlForest(htmldest, allLabelledTrees(trees));
    let* _          = exportJson(jsondest, trees);
    let* _          = BasicDb/DbMonad.runSQLite(storeIH06Trees(defaultTableNames(), src, Text/Charset.utf_8(), true), dbdest);
    Ok()


