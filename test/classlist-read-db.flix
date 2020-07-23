use System.Error.{Generic};

use AssetLib/S4/FileIO/ClassList/Relations.{FlocCharacteristic, EquiCharacteristic};
use AssetLib/S4/FileIO/ClassList/SQLiteLoader.{loadClassListDb};

def runResult(r1: Result[reln, System.Error]): reln & Impure = match r1 {
    case Ok(reln) => reln
    case Err(e) => {
        Console.printLine(System/Error.toString(e));
        #{ }
    }
}

def main(): #{EquiCharacteristic} & Impure =  
    use Result.flatMap;
    let step = () -> {
        let path  = System/FilePath.new("G:/work/Projects/assets/facts/characteristics_db.sqlite");
        let* relns = loadCharacteristicsDb(path);
        let r1 = project EquiCharacteristic relns;
        Ok(r1)
    };
    step() |> runResult
