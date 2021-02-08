

def main(_args: Array[String]): Int32 & Impure = 
    use BasicDb/DbMonad.{runSQLite};
    use AssetLib/S4/FileIO/TransferFile/Builtins.{storeValuaEquiFile};
    Console.printLine("Running...");
    let dbpath = System/FilePath.new("G:/work/assets/elaborate/elaborate.sqlite");
    let valuaEqui = System/FilePath.new("G:/work/assets/elaborate/sample_valuaequi.txt");
    match runSQLite(storeValuaEquiFile("valuaequi", true, valuaEqui), dbpath) {
        case Ok() => {Console.printLine("Wrote: ${dbpath}"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }
