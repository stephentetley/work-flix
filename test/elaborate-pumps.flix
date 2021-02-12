use Elaborator.ElaborateMonad;

def main(_args: Array[String]): Int32 & Impure = 
    use BasicDb/DbMonad.{runSQLite, flatMap, return};
    use AssetLib/S4/FileIO/TransferFile/Builtins.{storeValuaEquiFile, initValuaFlocTable};
    Console.printLine("Running...");
    let dbpath      = System/FilePath.new("G:/work/assets/elaborate/elaborate.sqlite");
    let valuaEquis  = System/FilePath.new("G:/work/assets/elaborate/sample_valuaequi.txt");
    let tables      = {equiTableName = "valuaequi", flocTableName = "valuafloc"};
    let outpath     = System/FilePath.new("G:/work/assets/elaborate/valuaequi_upload.txt");
    let action      = () -> {
        let* _  = storeValuaEquiFile(tables.equiTableName, true, valuaEquis);
        let* _  = initValuaFlocTable(tables.flocTableName);
        let* _  = Elaborator/ElaborateMonad.runElaborateMonad(elaborateAib(outpath), tables);
        return()
    };
    match runSQLite(action(), dbpath) {
        case Ok() => {Console.printLine("Wrote: ${dbpath} & ${outpath}"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }


def elaborateAib(outpath: System.FilePath): ElaborateMonad[Unit] = 
    use AssetLib/S4/FileIO/TransferFile/Builtins.{outputValuaEquiFile};
    use Elaborator/ElaborateMonad.{flatMap, return, liftAction};
    let* r1 = Elaborator/CreateUploadRow.nextStringValuaEqui("101000245", "AI2_AIB_REFERENCE", "XXYZ000001");
    let* r2 = Elaborator/CreateUploadRow.nextStringValuaEqui("101002121", "AI2_AIB_REFERENCE", "XXYZ000002");
    let* r3 = Elaborator/CreateUploadRow.nextStringValuaEqui("101026773", "AI2_AIB_REFERENCE", "XXYZ000003");
    let* _  = liftAction(_ -> outputValuaEquiFile("tetleys", r1 :: r2 :: r3 :: Nil, outpath));
    return()