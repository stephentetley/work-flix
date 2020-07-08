use AssetLib/S4/FileIO/ZTable/Relations.{Eqobjl, Flocdes, Floobjl, Manuf, Obj};
use AssetLib/S4/FileIO/ZTable/BuiltinLoaders.{DbPaths, loadDb, loadFloobjl};
use AssetLib/S4/FileIO/ZTable/Derive.{Level, flocLevel};

def runResult(r1: Result[reln, System.Error]): reln & Impure = match r1 {
    case Ok(reln) => reln
    case Err(e) => {
        Console.printLine(System/Error.toString(e));
        #{ }
    }
}


def paths(): DbPaths = 
    { pathOfEqobjl  = "G:/work/Projects/assets/facts/ztables/ztable_eqobjl.txt"
    , pathOfFlocdes = "G:/work/Projects/assets/facts/ztables/ztable_flocdes.txt"
    , pathOfFloobjl = "G:/work/Projects/assets/facts/ztables/ztable_floobjl.txt"
    , pathOfManuf   = "G:/work/Projects/assets/facts/ztables/ztable_manuf.txt"
    , pathOfObj     = "G:/work/Projects/assets/facts/ztables/ztable_obj.txt"
    }

// def loadDB[r](): Result[#{ Eqobjl, Flocdes, Floobjl, Manuf, Obj | r }, System.Error] & Impure =
//     loadDb(paths())
    


def main(): #{ Level } & Impure =
    use Result.flatMap;
    let step = () -> {
        let* db = loadFloobjl(paths().pathOfFloobjl);
        let _ = Console.printLine("Solving...");
        let lvl = flocLevel(db);
        Ok(lvl)
    };
    step() |> runResult
    

// def main(): #{ Floobjl } & Impure =
//     use Result.flatMap;
//     let step = () -> {
//         let* db = loadDB();
//         let ans = project Floobjl (solve db);
//         Ok(ans)
//     };
//     step() |> runResult
        