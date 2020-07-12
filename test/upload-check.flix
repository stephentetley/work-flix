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
use UploadCheck/EntityTypes/ValuaEqui.{ValuaEqui};
use UploadCheck/Checkers/TypeCheck.{Value, TypeFail, typecheck, tempTypeDb, deriveValues};

def main(): #{ TypeFail } = 
    let r1 = #{ 
        ValuaEqui( 1, "101000245", "002", "AI2_AIB_REFERENCE", "PLI00343356", 1, "PLI00343356", 1, "", "").
        ValuaEqui( 2, "101001660", "002", "EASTING", "PLI00343356", 1, "PLI00343356", 1, "", "").           // type error
    };
    let ans = (solve typecheck() <+> deriveValues() <+> r1 <+> tempTypeDb());
    project TypeFail ans
