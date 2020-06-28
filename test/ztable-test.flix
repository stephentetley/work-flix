use AssetLib/S4/FileReaders/ZTable/Relations.{ManufacturerModel, ObjectTypeManufacturer};

def runResult(r1: Result[reln, System.Error]): reln & Impure = match r1 {
    case Ok(reln) => reln
    case Err(e) => {
        Console.printLine(System/Error.toString(e));
        #{ }
    }
}



def loadDB[r](): Result[#{ ManufacturerModel, ObjectTypeManufacturer | r }, System.Error] & Impure =
    use Result.flatMap;
    use AssetLib/S4/FileReaders/ZTable/BuiltinLoaders.{loadManufacturerModel, loadObjectTypeManufacturer};
    let* r1 = loadManufacturerModel("G:/work/Projects/assets/facts/ztable-manufacturer-model.txt");
    let* r2 = loadObjectTypeManufacturer("G:/work/Projects/assets/facts/ztable-objecttype-manufacturer.txt");
    Ok(r1 <+> r2)
    


def main(): #{ManufacturerModel} & Impure =
    use Result.flatMap;
        let step = () -> {
        let* db = loadDB();
        let mm = project ManufacturerModel db;
        Ok(mm)
    };
    step() |> runResult
    