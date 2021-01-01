use System.Error.{Generic};

use AssetLib/Common/ExportHtmlTree.{writeHtmlForest};
use AssetLib/S4/FileIO/IH06Tree/Parser.{parseFileWithBOM};
use AssetLib/S4/FileIO/IH06Tree/Builder.{buildIH06Trees, allTrees};
use AssetLib/S4/FileIO/IH06Tree/ExportCsv.{CsvOutputPaths, exportCsv};
use AssetLib/S4/FileIO/IH06Tree/ExportDb.{defaultTableNames, storeIH06Trees};
    

def csvDest(): CsvOutputPaths = 
    { flocOutpath = System/FilePath.new("G:/work/assets/capital_schemes/wethe-ih06-flocs.csv")
    , equiOutpath = System/FilePath.new("G:/work/assets/capital_schemes/wethe-ih06-equis.csv")
    }

def main(): Result[Unit, System.Error] & Impure =
    use Result.flatMap;
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06-all.txt");
    let htmldest    = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06.html");
    let dbdest      = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06.sqlite");
    let* _          = exportCsv(src, Text/Charset.utf_8(), true, csvDest());    
    let* ast        = parseFileWithBOM(src, Text/Charset.utf_8());
    let _           = Console.printLine("Count: " + Int32.toString(List.length(ast.rows))); 
    let trees       = buildIH06Trees(ast);
    let* _          = writeHtmlForest(htmldest, allTrees(trees));
    let* _          = BasicDb/DbMonad.runSQLite(storeIH06Trees(defaultTableNames(), src, Text/Charset.utf_8(), true), dbdest);
    Ok()


