
use AssetLib/FileIO/S4/UxlFile/Datatypes.{EqClassification};
use AssetLib/FileIO/S4/ClassList/Relations.{ClassMember};
use AssetLib/FileIO/S4/ClassList/SQLiteLoader.{CharacteristicsDb, loadCharacteristicsDb};

use UploadCheck/DatalogCheckers/CharacteristicInClassCheck.{characteristicInClassCheck};
use UploadCheck/DatalogCheckers/SelectionValueCheck.{selectionValueCheck};
use UploadCheck/DatalogCheckers/IntRangeCheck.{intRangeCheck};



// def runChecks[r](db: CharacteristicsDb[r], row: EqClassification): Bool =
//     let x1 = characteristicInClassCheck(project ClassMember db, row.className, row.characteristicName);
//     // let x2 = selectionValueCheck(project SelectionValue db, row.characteristicName, row.charValue);
//     // let x3 = intRangeCheck(db, row.characteristicName, row.charValue);
//     x1 // (x1 and x2)
    
def runCharacteristicInClassCheck(db: #{ClassMember}, row: EqClassification): Bool = 
    characteristicInClassCheck(project ClassMember db, row.className, row.characteristicName)

def main(): Unit & Impure = 
    use Result.{flatMap};
    let step = () -> {
        let dbPath      = System/FilePath.new("G:/work/assets/facts/equi_characteristics.sqlite");
        let* db         = loadCharacteristicsDb(dbPath);
        let uxlSrc      = System/FilePath.new("G:/work/assets/uxl/eq_characteristics.csv");
        let* rows       = AssetLib/FileIO/S4/UxlFile/CsvReader.loadEqClassifications(uxlSrc);
        let db1         = project ClassMember db;
        let _           = Console.printLine("Running...");
        let _           = List.foreach(x -> if (runCharacteristicInClassCheck(db1, x)) Console.printLine("ok") else Console.printLine("check failed"), rows);
        Ok()
    };
    step() |> _ -> ()


