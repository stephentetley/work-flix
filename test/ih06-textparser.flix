use System.Error.{Generic};

use AssetLib/Common/ExportHtmlTree.{writeHtmlForest};
use AssetLib/S4/FileIO/IH06Tree/Raw/Parser.{parseFile};
use AssetLib/S4/FileIO/IH06Tree/Raw/Builder.{buildIH06Trees, allTrees};
use AssetLib/S4/FileIO/IH06Tree/Raw/ExportCsv.{CsvOutputPaths, exportCsv};
use AssetLib/S4/FileIO/IH06Tree/Raw/ExportDb.{exportDb};
    

def csvDest(): CsvOutputPaths = 
    { flocOutpath = System/FilePath.new("G:/work/Projects/assets/capital_schemes/eastn/eastn_ih06_flocs.csv")
    , equiOutpath = System/FilePath.new("G:/work/Projects/assets/capital_schemes/eastn/eastn_ih06_equis.csv")
    }

@test
def main(): Result[Unit, System.Error] & Impure =
    use Result.flatMap;
    let src = System/FilePath.new("G:/work/Projects/assets/capital_schemes/eastn/eastn-ih06.txt");
    let htmldest = System/FilePath.new("E:/coding/work/work-flix/output/eastn_ih06_tree.html");
    let* _      = exportCsv(src, csvDest());    
    let* ast    = parseFile(src);
    let trees   = buildIH06Trees(ast);
    let* _      = writeHtmlForest(htmldest, allTrees(trees));
    let* _      = exportDb(src, System/FilePath.new("G:/work/Projects/assets/capital_schemes/eastn/eastn_ih06.sqlite"));
    Ok()


