use AssetLib/S4/FileIO/ZTable/Relations.{Eqobjl, Flocdes, Floobjl, Manuf, Obj};
use AssetLib/S4/FileIO/ZTable/BuiltinLoaders.{DbPaths, loadDb, loadFloobjl};
use AssetLib/S4/FileIO/ZTable/Derive.{Level, flocLevel, validChild};

def runResult(r1: Result[reln, System.Error]): reln & Impure = match r1 {
    case Ok(reln) => reln
    case Err(e) => {
        Console.printLine(System/Error.toString(e));
        #{ }
    }
}


def paths(): DbPaths = 
    { pathOfEqobjl  = System/FilePath.new("G:/work/Projects/assets/facts/ztables/ztable_eqobjl.txt")
    , pathOfFlocdes = System/FilePath.new("G:/work/Projects/assets/facts/ztables/ztable_flocdes.txt")
    , pathOfFloobjl = System/FilePath.new("G:/work/Projects/assets/facts/ztables/ztable_floobjl.txt")
    , pathOfManuf   = System/FilePath.new("G:/work/Projects/assets/facts/ztables/ztable_manuf.txt")
    , pathOfObj     = System/FilePath.new("G:/work/Projects/assets/facts/ztables/ztable_obj.txt")
    }

// def loadDB[r](): Result[#{ Eqobjl, Flocdes, Floobjl, Manuf, Obj | r }, System.Error] & Impure =
//     loadDb(paths())
    

// def tempDb[r](): #{Floobjl | r} = #{ 
//     Floobjl("YW-GS", "SITE", "WWT").
//     Floobjl("YW-GS", "WWT", "SCT").
//     Floobjl("YW-GS", "SCT", "ASP").
//     Floobjl("YW-GS", "ASP", "SDOS").
// }

def levels(): #{Level} & Impure =
    use Result.flatMap;
    let step = () -> {
        let* db = loadFloobjl(paths().pathOfFloobjl);
        // let db = tempDb();
        let _ = Console.printLine("Solving...");
        let lvl = flocLevel(db, "YW-GS", "SDOS");
        Ok(lvl)
    };
    step() |> runResult
    

// def valid1(): Result[Bool, System.Error] & Impure =
//     use Result.flatMap;
//     let step = () -> {
//         let* db = loadFloobjl(paths().pathOfFloobjl);
//         let _ = Console.printLine("Solving...");
//         let ans = validChild(db, "SDOS");
//         Ok(ans)
//     };
//     step()
    

def main(): #{Level} & Impure = levels()