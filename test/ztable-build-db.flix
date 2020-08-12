
use AssetLib/S4/FileIO/ZTable/Raw/BuiltinParsers.{DbPaths, loadDb};
use AssetLib/S4/FileIO/ZTable/Raw/ExportDb.{outputDb};



def paths(): DbPaths = 
    { pathOfEqobjl  = System/FilePath.new("G:/work/Projects/assets/facts/ztables/ztable_eqobjl.txt")
    , pathOfFlocdes = System/FilePath.new("G:/work/Projects/assets/facts/ztables/ztable_flocdes.txt")
    , pathOfFloobjl = System/FilePath.new("G:/work/Projects/assets/facts/ztables/ztable_floobjl.txt")
    , pathOfManuf   = System/FilePath.new("G:/work/Projects/assets/facts/ztables/ztable_manuf.txt")
    , pathOfObj     = System/FilePath.new("G:/work/Projects/assets/facts/ztables/ztable_obj.txt")
    }


    

def main(): Result[Unit, System.Error] & Impure = 
    use Result.{flatMap};
    use System/FilePath.{toString};
    let* db = loadDb(paths());
    let outpath = System/FilePath.new("G:/work/Projects/assets/facts/ztables/ztables.sqlite");
    outputDb(db, outpath)