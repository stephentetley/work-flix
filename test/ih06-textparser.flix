use System.Error.{Generic};

use AssetLib/Common/ExportHtmlTree.{writeHtmlForest};
use AssetLib/S4/FileIO/IH06Tree/Raw/Datatypes.{IH06File, Header, IH06Row, FlocRow, EquiRow};
use AssetLib/S4/FileIO/IH06Tree/Raw/Parser.{parseFile};
use AssetLib/S4/FileIO/IH06Tree/Raw/ExportCsv.{exportFlocCsv};
use AssetLib/S4/FileIO/IH06Tree/Raw/Builder.{buildIH06Trees, allTrees};
use AssetLib/S4/FileIO/IH06Tree/TransposeRaw.{TransposeRawParams, transposeRawInput};
    

def rawParams(): TransposeRawParams = 
    { flocOutpath = System/FilePath.new("G:/work/Projects/assets/capital_schemes/ear02/ear02_ih06_flocs.csv")
    , equiOutpath = System/FilePath.new("G:/work/Projects/assets/capital_schemes/ear02/ear02_ih06_equis.csv")
    }

@test
def main(): Result[Unit, System.Error] & Impure =
    use Result.flatMap;
    let src = System/FilePath.new("G:/work/Projects/assets/ih06_trees/catte_ih06_export.txt");
    let htmldest = System/FilePath.new("E:/coding/work/work-flix/output/catte_ih06__tree.html");
    let* _      = transposeRawInput(src, rawParams());    
    let* ast    = parseFile(src);
    let trees   = buildIH06Trees(ast);
    let* _      = writeHtmlForest(htmldest, allTrees(trees));
    Ok()


