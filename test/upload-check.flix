use AssetLib/S4/FileIO/ChangeFile/Datatypes.ChangeFile.{ChangeFile};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.Headers.{Headers};
use UploadCheck/EntityTypes/ValuaFloc.{ValuaFloc, parseFile, getRelations};

def main(): #{ ValuaFloc } & Impure = 
    use Result.flatMap;
    let step = () -> {
        let src = "G:/work/Projects/assets/asset_patch/mmim_upgrade_2019/patch_output/outstation_patch_04_create_valuaflocs.txt";    
        // let* ast = AssetLib/S4/FileIO/ChangeFile/Parser.parseFile(src);
        let* ast = parseFile(src);
        let relns = getRelations(ast);
        Ok(solve relns)
    };
    let db = step() |> x -> Result.getWithDefault(x, #{ });
    project ValuaFloc db


