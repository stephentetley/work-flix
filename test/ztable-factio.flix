use AssetLib/S4/FileReaders/ZTable/Relations.{Eqobjl, Flocdes, Floobjl, Manuf, Obj};

def runResult(r1: Result[reln, System.Error]): reln & Impure = match r1 {
    case Ok(reln) => reln
    case Err(e) => {
        Console.printLine(System/Error.toString(e));
        #{ }
    }
}



def loadDB[r](): Result[#{ Eqobjl, Flocdes, Floobjl, Manuf, Obj | r }, System.Error] & Impure =
    use AssetLib/S4/FileReaders/ZTable/BuiltinLoaders.{loadDb};
    let paths = { pathOfEqobjl  = "G:/work/Projects/assets/facts/ztable_eqobjl.txt"
                , pathOfFlocdes = "G:/work/Projects/assets/facts/ztable_flocdes.txt"
                , pathOfFloobjl = "G:/work/Projects/assets/facts/ztable_floobjl.txt"
                , pathOfManuf   = "G:/work/Projects/assets/facts/ztable_manuf.txt"
                , pathOfObj     = "G:/work/Projects/assets/facts/ztable_obj.txt"
                };
    loadDb(paths)
    


def main(): #{ Manuf } & Impure =
    use Result.flatMap;
    let step = () -> {
        let* db = loadDB();
        let mm = project Manuf db;
        Ok(mm)
    };
    step() |> runResult
    