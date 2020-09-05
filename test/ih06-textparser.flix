use System.Error.{Generic};

use AssetLib/Common/ExportHtmlTree.{writeHtmlForest};
use AssetLib/S4/FileIO/IH06Tree/Raw/Parser.{parseFileWithBOM};
use AssetLib/S4/FileIO/IH06Tree/Raw/Builder.{buildIH06Trees, allTrees};
use AssetLib/S4/FileIO/IH06Tree/Raw/ExportCsv.{CsvOutputPaths, exportCsv};
use AssetLib/S4/FileIO/IH06Tree/Raw/ExportDb.{exportDb};
    

def csvDest(): CsvOutputPaths = 
    { flocOutpath = System/FilePath.new("G:/work/assets/capital_schemes/sto18_ih06_flocs.csv")
    , equiOutpath = System/FilePath.new("G:/work/assets/capital_schemes/sto18_ih06_equis.csv")
    }

// def temp(): Result[Unit, System.Error] & Impure = 
//     use Result.flatMap;
//     let src     = System/FilePath.new("G:/work/assets/capital_schemes/sto18_ih06.txt");
//     let* str    = System/File.readFileWithBOM(src, Text/Charset.utf_8());
//     let _       = Console.printLine("@@@" + String.take(10, str));
//     Ok()



def main(): Result[Unit, System.Error] & Impure =
    use Result.flatMap;
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/sto18_ih06.txt");
    let htmldest    = System/FilePath.new("E:/coding/work/work-flix/output/sto18_ih06.html");
    let* _          = exportCsv(src, Text/Charset.utf_8(), true, csvDest());    
    let* ast        = parseFileWithBOM(src, Text/Charset.utf_8());
    let _           = Console.printLine("Count: " + Int32.toString(List.length(ast.rows))); 
    let trees       = buildIH06Trees(ast);
    let* _          = writeHtmlForest(htmldest, allTrees(trees));
    // let* _      = exportDb(src, System/FilePath.new("G:/work/Projects/assets/capital_schemes/eastn/eastn_ih06.sqlite"));
    Ok()


