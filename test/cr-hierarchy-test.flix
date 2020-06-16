
use AssetLib/S4/Hierarchy/Relations.{Node};

def runResult(r1: Result[reln, System.Error]): reln & Impure = match r1 {
    case Ok(reln) => reln
    case Err(e) => {
        Console.printLine(System/Error.toString(e));
        #{ }
    }
}





def loadDB[r](): Result[#{ Node | r }, System.Error] & Impure =
    use Result.flatMap;
    use AssetLib/S4/Hierarchy/ChangeFileLoader.{loadEqui, loadFloc};
    let* r1 = loadEqui("G:/work/Projects/assets/otl07/wat43_equi_file_download.txt");
    let* r2 = loadFloc("G:/work/Projects/assets/otl07/wat43_floc_FLOC_REF_file_download.txt");
    let* r3 = loadFloc("G:/work/Projects/assets/otl07/wat43_floc_FUNCLOC_file_download.txt");
    Ok(r1 <+> r2 <+> r3)
    


def main(): List[String] & Impure =
    use Result.flatMap;
    use AssetLib/S4/Hierarchy/BuildHierarchy.{getRoots};
    let step = () -> {
        let* db = loadDB();
        let xs = getRoots(db);
        Ok(xs)
    };
    step() |> runResult