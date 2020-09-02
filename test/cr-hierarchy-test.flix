
use AssetLib/S4/Hierarchy/Relations.{Node};
use AssetLib/S4/Hierarchy/BuildHierarchy.{Label};

// def runResult(r1: Result[reln, System.Error]): reln & Impure = match r1 {
//     case Ok(reln) => reln
//     case Err(e) => {
//         Console.printLine(System/Error.toString(e));
//         #{ }
//     }
// }



def loadDB[r](): Result[#{ Node | r }, System.Error] & Impure =
    use Result.flatMap;
    use AssetLib/S4/Hierarchy/HierarchyLoader.{loadEqui, loadFloc};
    let* r1 = loadEqui(System/FilePath.new("G:/work/assets/capital_schemes/otl07/wat43_equi_file_download.txt"));
    let* r2 = loadFloc(System/FilePath.new("G:/work/assets/capital_schemes/otl07/wat43_floc_FLOC_REF_file_download.txt"));
    let* r3 = loadFloc(System/FilePath.new("G:/work/assets/capital_schemes/otl07/wat43_floc_FUNCLOC_file_download.txt"));
    Ok(r1 <+> r2 <+> r3)
    


def main(): Result[Unit, System.Error] & Impure =
    use Result.flatMap;
    use AssetLib/Common/ExportHtmlTree.{writeHtmlForest};
    use AssetLib/S4/Hierarchy/BuildHierarchy.{allTrees};
    let dest = System/FilePath.new("e:/coding/work/work-flix/output/Tree.html");
    let* db = loadDB();
    let xs = allTrees(db);
    writeHtmlForest(dest, xs)
    