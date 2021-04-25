use Elaborator.ElaborateMonad;

def main(_args: Array[String]): Int32 & Impure = 
    use Elaborator/ElaborateMonad.{runElaborateMonadSQLite};
    Console.printLine("Running...");
    let dbpath      = System/FilePath.new("G:/work/assets/elaborate/elaborate.sqlite");
    let valuaEquis  = System/FilePath.new("G:/work/assets/elaborate/sample_valuaequi.txt");
    let outpath     = System/FilePath.new("G:/work/assets/elaborate/valuaequi_upload.txt");
    match runElaborateMonadSQLite(elaborateAib(valuaEquis, outpath), dbpath) {
        case Ok() => {Console.printLine("Wrote: ${dbpath} & ${outpath}"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }

/// This is just a dummy, need to the dataset to do real work...
def elaborateAib(valuaEqui: System.FilePath, outpath: System.FilePath): ElaborateMonad[Unit] = 
    use AssetLib/FileIO/S4/TransferFile/Builtins.{outputValuaEquiFile};
    use Elaborator/ElaborateMonad.{flatMap, return, liftAction, storeValuaEquiFile};
    let* _  = storeValuaEquiFile(valuaEqui);
    let* r1 = Elaborator/CreateUploadRow.nextStringValuaEqui("101000245", "AI2_AIB_REFERENCE", "XXYZ000001");
    let* r2 = Elaborator/CreateUploadRow.nextStringValuaEqui("101002121", "AI2_AIB_REFERENCE", "XXYZ000002");
    let* r3 = Elaborator/CreateUploadRow.nextStringValuaEqui("101026773", "AI2_AIB_REFERENCE", "XXYZ000003");
    let* _  = liftAction(_ -> outputValuaEquiFile("tetleys", r1 :: r2 :: r3 :: Nil, outpath));
    return()
