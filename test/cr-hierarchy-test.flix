
use AssetLib/S4/Hierarchy/BuildHierarchy.{Node};

def runResult(r1: Result[reln, System.Error]): reln & Impure = match r1 {
    case Ok(reln) => reln
    case Err(e) => {
        Console.printLine(System/Error.toString(e));
        #{ }
    }
}

    
@test
def main[r](): #{ Node | r } & Impure =
    use AssetLib/S4/Hierarchy/BuildHierarchy.{loadEqui, loadFloc};
    use Result.flatMap;
    let step = () -> {
        let* r1 = loadEqui("G:/work/Projects/assets/otl07/wat43_equi_file_download.txt");
        let* r2 = loadFloc("G:/work/Projects/assets/otl07/wat43_floc_FLOC_REF_file_download.txt");
        let* r3 = loadFloc("G:/work/Projects/assets/otl07/wat43_floc_FUNCLOC_file_download.txt");
        Ok(solve r1 <+> r2 <+> r3)
    };
    step() |> runResult