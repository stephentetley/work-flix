use System.Error.{Generic};

use AssetLib/Common/ExportHtmlTree.{writeHtmlForest};
use AssetLib/S4/FileReaders/IH06Tree/Raw/Datatypes.{IH06File, Header, IH06Row, FlocRow, EquiRow};
use AssetLib/S4/FileReaders/IH06Tree/Raw/Parser.{parseFile};
use AssetLib/S4/FileReaders/IH06Tree/Raw/ExportCsv.{exportCsv};
use AssetLib/S4/FileReaders/IH06Tree/Raw/Builder.{buildIH06Trees, allTrees};
    
@test
def main(): Result[Unit, System.Error] & Impure =
    use Result.flatMap;
    let src = "G:/work/Projects/assets/capital_schemes/ear02/ear02_ih06_export.txt";    
    let csvdest = "G:/work/Projects/assets/capital_schemes/ear02/ear02_ih06_export.csv";
    let htmldest = "E:/coding/work/work-flix/output/ear02_ih06_tree.html";
    let* ast    = parseFile(src);
    let _       = Console.printLine("parsed");
    let* _      = exportCsv(ast, csvdest);
    let trees   = buildIH06Trees(ast);
    let _       = Console.printLine("Tree count: " + Int32.toString(List.length(trees)));
    let* _  = writeHtmlForest(htmldest, allTrees(trees));
    Ok()


