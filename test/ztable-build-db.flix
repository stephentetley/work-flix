
use AssetLib/S4/FileIO/ZTable/ExportDb.{ZTableSourcePaths, storeZTableFiles, defaultTableNames};



def paths(): ZTableSourcePaths = 
    { eqobjlPath    = System/FilePath.new("G:/work/assets/facts/ztables/ztable_eqobjl.txt")
    , flocdesPath   = System/FilePath.new("G:/work/assets/facts/ztables/ztable_flocdes.txt")
    , floobjlPath   = System/FilePath.new("G:/work/assets/facts/ztables/ztable_floobjl.txt")
    , manufPath     = System/FilePath.new("G:/work/assets/facts/ztables/ztable_manuf.txt")
    , objPath       = System/FilePath.new("G:/work/assets/facts/ztables/ztable_obj.txt")
    }


    

def main(): Result[Unit, System.Error] & Impure = 
    use BasicDb/DbMonad.{runSQLite};
    let outpath = System/FilePath.new("G:/work/assets/facts/ztable_facts.sqlite");
    let srcpaths = paths();
    runSQLite(storeZTableFiles(defaultTableNames(), srcpaths), outpath)
