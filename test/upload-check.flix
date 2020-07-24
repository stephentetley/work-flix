// use AssetLib/S4/FileIO/ChangeFile/Datatypes.ChangeFile.{ChangeFile};
// use AssetLib/S4/FileIO/ChangeFile/Datatypes.Headers.{Headers};
// use UploadCheck/EntityTypes/ValuaFloc.{ValuaFloc, parseFile, getRelations};

// def main(): #{ ValuaFloc } & Impure = 
//     use Result.flatMap;
//     let step = () -> {
//         let src = "G:/work/Projects/assets/asset_patch/mmim_upgrade_2019/patch_output/outstation_patch_04_create_valuaflocs.txt";    
//         // let* ast = AssetLib/S4/FileIO/ChangeFile/Parser.parseFile(src);
//         let* ast = parseFile(src);
//         let relns = getRelations(ast);
//         Ok(solve relns)
//     };
//     let db = step() |> x -> Result.getWithDefault(x, #{ });
//     project ValuaFloc db

use AssetLib/S4/FileIO/ClassList/Relations.Datatype.{Text};
use AssetLib/S4/FileIO/ClassList/SQLiteLoader.{loadCharacteristicsDb};
use UploadCheck/EntityTypes/ValuaEqui.{ValuaEqui};
use UploadCheck/Checkers/CharacteristicTypeCheck.{Value, TypeFail, equiTypecheck};


// def main(): #{EquiCharacteristic} & Impure =  
//     use Result.flatMap;
//     let step = () -> {
//         let path  = System/FilePath.new("G:/work/Projects/assets/facts/characteristics_db.sqlite");
//         let* relns = loadDb(path);
//         let r1 = project EquiCharacteristic relns;
//         Ok(r1)
//     };
//     step() |> runResult

def typeCheck(): Result[#{TypeFail}, System.Error] & Impure = 
    use Result.{flatMap};
    let charsPath  = System/FilePath.new("G:/work/Projects/assets/facts/equi_characteristics.sqlite");
    let* characteristics = loadCharacteristicsDb(charsPath);
    let r1 = #{ 
        ValuaEqui( 1, "101000245", "002", "AI2_AIB_REFERENCE", "PLI00343356", 1, "PLI00343356", 1, "", "").
        ValuaEqui( 2, "101001660", "002", "EASTING", "PLI00343356", 1, "PLI00343356", 1, "", "").           // type error
        ValuaEqui( 3, "101000245", "002", "VEPR_PV_VERIFICATION_DATE", "2019.06.12", 1, "2019.06.12", 1, "", "").   // type error   
    };
    let ans = (solve equiTypecheck() <+> r1 <+> characteristics);
    Ok(project TypeFail ans)


def main(): #{TypeFail} & Impure = 
    match typeCheck() {
        case Err(_) => #{}
        case Ok(reln) => reln
    }