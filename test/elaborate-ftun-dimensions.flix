use BasicDb.DbMonad;
use BasicDb.RowEvaluator;
use AssetLib/FileIO/S4/TransferFile/Builtins.{ValuaEquiRow};
use Elaborator.ElaborateMonad;


def main(_args: Array[String]): Int32 & Impure = 
    use Elaborator/ElaborateMonad.{runElaborateMonadSQLite};
    Console.printLine("Running...");
    let dbpath      = System/FilePath.new("G:/work/assets/elaborate/ftun.sqlite");
    let valuaEquis  = System/FilePath.new("G:/work/assets/elaborate/file_download_valuaequi_FTUN_m.txt");
    let outpath     = System/FilePath.new("G:/work/assets/elaborate/ftun_mm_upload.txt");
    match runElaborateMonadSQLite(elaborateAib(valuaEquis, outpath), dbpath) {
        case Ok() => {Console.printLine("Wrote: ${dbpath} & ${outpath}"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }

/// This is just a dummy, need to the dataset to do real work...
def elaborateAib(valuaEqui: System.FilePath, outpath: System.FilePath): ElaborateMonad[Unit] = 
    use AssetLib/FileIO/S4/TransferFile/Builtins.{outputValuaEquiFile};
    use Elaborator/ElaborateMonad.{flatMap, return, liftAction, storeValuaEquiFile, liftDbMonad, mapM};
    let* _      = storeValuaEquiFile(valuaEqui);
    let* input  = liftDbMonad(getDimensionRows());
    let* xs     = mapM(nextScaledValuaEqui, input);
    let* _      = liftAction(_ -> outputValuaEquiFile("tetleys", xs, outpath));
    return()

pub def nextScaledValuaEqui(x: EquiDecimalValue): ElaborateMonad[ValuaEquiRow] =
    use Elaborator/CreateUploadRow.{nextFloat64ValuaEqui};
    nextFloat64ValuaEqui(x.equiId, x.characteristicName + "M", x.value * 1000.0f64)

type alias EquiDecimalValue = 
    { equiId: String
    , characteristicName: String
    , counter: Int32
    , value: Float64
    }
    
pub def getDimensionRows(): DbMonad[List[EquiDecimalValue]] = 
    use BasicDb/DbMonad.{flatMap, return, createStatement, executeQuery, allRows, rsClose};
    let* stmt   = createStatement();
    let* rs     = executeQuery(stmt, ftunDimRowQuerySql());
    let* xs     = allRows(rs, evalValuaEquiDecimalRow());
    let* _      = rsClose(rs);
    return(xs)


def ftunDimRowQuerySql(): String = 
    String.unlines(
            "SELECT"
        :: "    t1.equi as equi_id,"
        :: "    t1.char_id as char_id,"
        :: "    t1.int_counter_value as counter_idx,"
        :: "    t1.value_from as decimal_value"
        :: "FROM"
        :: "    valuaequi t1"
        :: "WHERE"
        :: "    t1.char_id LIKE 'FTUN_%M'"
        :: Nil
    )


def evalValuaEquiDecimalRow(): RowEvaluator[EquiDecimalValue] = 
    use BasicDb/RowEvaluator.{getStringNamed, getInt32Named, getFloat64Named};
    use BasicDb/RowEvaluator.{<&>, <*>};
    ((x1, x2, x3, x4) ->
            { equiId                = x1
            , characteristicName    = x2
            , counter               = x3
            , value                 = x4
            })
        <&> getStringNamed("equi_id")
        <*> getStringNamed("char_id")
        <*> getInt32Named("counter_idx")
        <*> getFloat64Named("decimal_value")