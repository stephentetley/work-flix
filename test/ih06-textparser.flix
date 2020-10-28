use System.Error.{Generic};

use AssetLib/Common/ExportHtmlTree.{writeHtmlForest};
use AssetLib/S4/FileIO/IH06Tree/Parser.{parseFileWithBOM};
use AssetLib/S4/FileIO/IH06Tree/Builder.{buildIH06Trees, allTrees};
use AssetLib/S4/FileIO/IH06Tree/ExportCsv.{CsvOutputPaths, exportCsv};
use AssetLib/S4/FileIO/IH06Tree/ExportDb.{exportDb};
    

def csvDest(): CsvOutputPaths = 
    { flocOutpath = System/FilePath.new("G:/work/assets/capital_schemes/ih06-lob02-e-hv_flocs.csv")
    , equiOutpath = System/FilePath.new("G:/work/assets/capital_schemes/ih06-lob02-e-hv_equis.csv")
    }

// def temp(): Result[Unit, System.Error] & Impure = 
//     use Result.flatMap;
//     let src     = System/FilePath.new("G:/work/assets/capital_schemes/sto18_ih06.txt");
//     let* str    = System/File.readFileWithBOM(src, Text/Charset.utf_8());
//     let _       = Console.printLine("@@@" + String.take(10, str));
//     Ok()

// ih06-lob02-e-hv.txt is not rooted...

def main(): Result[Unit, System.Error] & Impure =
    use Result.flatMap;
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/ih06-lob02-e-hv.txt");
    let htmldest    = System/FilePath.new("E:/coding/work/work-flix/output/ih06-lob02-e-hv.html");
    let* _          = exportCsv(src, Text/Charset.utf_8(), true, csvDest());    
    let* ast        = parseFileWithBOM(src, Text/Charset.utf_8());
    let _           = Console.printLine("Count: " + Int32.toString(List.length(ast.rows))); 
    let trees       = buildIH06Trees(ast);
    let* _          = writeHtmlForest(htmldest, allTrees(trees));
    // let* _      = exportDb(src, System/FilePath.new("G:/work/Projects/assets/capital_schemes/eastn/eastn_ih06.sqlite"));
    Ok()


