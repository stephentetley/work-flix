use AssetLib/S4/FileIO/ChangeFile/Datatypes.ChangeFile.{ChangeFile};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.Headers.{Headers};

def main(): Result[Int32, System.Error] & Impure = 
    use Result.flatMap;
    let src = "G:/work/Projects/assets/asset_patch/mmim_upgrade_2019/patch_output/outstation_patch_04_create_valuaflocs.txt";    
    // let* ast = AssetLib/S4/FileIO/ChangeFile/Parser.parseFile(src);
    let* ast = UploadCheck/EntityTypes/ValuaFloc.parseFile(src);    
    let ChangeFile(body) = ast;
    let Headers(arr) = body.headers;
    let _ = Array.foreach(Console.printLine, arr);
    Ok(body.dataRows |> List.length)


