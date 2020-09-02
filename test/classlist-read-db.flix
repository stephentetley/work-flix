use System.Error.{Generic};

use AssetLib/S4/FileIO/ClassList/Relations.{Characteristic};


def runResult(r1: Result[#{| reln}, System.Error]): #{| reln} & Impure = match r1 {
    case Ok(reln) => reln
    case Err(e) => {
        Console.printLine(System/Error.toString(e));
        #{}
    }
}

def main(): #{Characteristic} & Impure =  
    use Result.flatMap;
    use AssetLib/S4/FileIO/ClassList/SQLiteLoader.{loadCharacteristicsDb};
    let step = () -> {
        let path  = System/FilePath.new("G:/work/assets/facts/equi_characteristics.sqlite");
        let* relns = loadCharacteristicsDb(path);
        let r1 = project Characteristic relns;
        Ok(r1)
    };
    step() |> runResult
