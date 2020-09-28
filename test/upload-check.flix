
use AssetLib/S4/FileIO/UxlFile/Datatypes.{EqClassification};
use AssetLib/S4/FileIO/ClassList/Relations.{ClassMember};
use AssetLib/S4/FileIO/ClassList/SQLiteLoader.{CharacteristicsDb, loadCharacteristicsDb};

use UploadCheck/Checkers/CharacteristicInClassCheck.{characteristicInClassCheck};
use UploadCheck/Checkers/SelectionValueCheck.{selectionValueCheck};
use UploadCheck/Checkers/IntRangeCheck.{intRangeCheck};



// def runChecks[r](db: CharacteristicsDb[r], row: EqClassification): Bool =
//     let x1 = characteristicInClassCheck(project ClassMember db, row.className, row.characteristicName);
//     // let x2 = selectionValueCheck(project SelectionValue db, row.characteristicName, row.charValue);
//     // let x3 = intRangeCheck(db, row.characteristicName, row.charValue);
//     x1 // (x1 && x2)
    
def runCharacteristicInClassCheck(db: #{ClassMember}, row: EqClassification): Bool = 
    characteristicInClassCheck(project ClassMember db, row.className, row.characteristicName)

def main(): Unit & Impure = 
    use Result.{flatMap};
    let step = () -> {
        let dbPath      = System/FilePath.new("G:/work/assets/facts/equi_characteristics.sqlite");
        let* db         = loadCharacteristicsDb(dbPath);
        let uxlSrc      = System/FilePath.new("G:/work/assets/uxl/eq_characteristics.csv");
        let* rows       = AssetLib/S4/FileIO/UxlFile/CsvReader.loadEqClassifications(uxlSrc);
        let db1         = project ClassMember db;
        let _           = Console.printLine("Running...");
        let _           = List.foreach(x -> if (runCharacteristicInClassCheck(db1, x)) Console.printLine("ok") else Console.printLine("check failed"), rows);
        Ok()
    };
    step() |> _ -> ()


