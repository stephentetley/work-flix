use System.Error.{Generic};

use BasicDb.DbMonad;

use AssetLib/S4/FileIO/ClassList/ExportDb.{defaultTableNames, storeFlocClassFile, storeEquiClassFile};

pub def main(_args: Array[String]): Int32 & Impure =         
    use BasicDb/DbMonad.{runSQLite};
    Console.printLine("Running...");
    match runSQLite(buildDb(), System/FilePath.new("G:/work/assets/facts/classfile_characteristics2.sqlite")) {
        case Ok() => {Console.printLine("Okay"); 0}
        case Err(msg) => {Console.printLine(msg); 1}
    }


def buildDb(): DbMonad[Unit] =  
    use BasicDb/DbMonad.{return, flatMap, liftAction};
    let names   = defaultTableNames();
    let* _      = storeFlocClassFile(names, true, System/FilePath.new("G:/work/assets/facts/floc-class-export.txt"), Text/Charset.iso_8859_1());
    let* _      = storeEquiClassFile(names, false, System/FilePath.new("G:/work/assets/facts/equi-class-export.txt"), Text/Charset.iso_8859_1());
    return()



