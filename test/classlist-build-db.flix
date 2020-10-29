use System.Error.{Generic};

use BasicDb.DbMonad;

use AssetLib/S4/FileIO/ClassList/ExportDb.{ClassListTableNames, storeFlocClassFile, storeEquiClassFile};

pub def main(): Result[Unit, System.Error] & Impure =         
    use BasicDb/DbMonad.{runSQLite};
    runSQLite(buildDb(), System/FilePath.new("G:/work/assets/facts/classfile_characteristics2.sqlite"))

def tableAliases(): ClassListTableNames = 
    { classMembers          = "cf_members"
    , characteristicDefs    = "cf_char_defs"
    , intRanges             = "cf_int_ranges"
    , decimalRanges         = "cf_decimal_ranges"
    , selectionValues       = "cf_selection_values"
    }


def buildDb(): DbMonad[Unit] =  
    use BasicDb/DbMonad.{return, flatMap};
    let tableNames = tableAliases();
    let* _      = storeFlocClassFile(tableNames, true, System/FilePath.new("G:/work/assets/facts/floc-class-export.txt"), Text/Charset.iso_8859_1());
    let* _      = storeEquiClassFile(tableNames, false, System/FilePath.new("G:/work/assets/facts/equi-class-export.txt"), Text/Charset.iso_8859_1());
    return()



