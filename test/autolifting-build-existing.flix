use BasicDb.DbMonad;
use AssetLib/S4/Simple/Datatypes.{S4Equipment};
use AssetLib/S4/Simple/EquipmentBuilder.{TableNames};


def main(): Unit & Impure = 
    use BasicDb/DbMonad.{runSQLite};   
    let dbpath = System/FilePath.new("G:/work/assets/lifting-equipment-reports/db1.sqlite");
    match runSQLite(build1("101000608"), dbpath) {
        case Ok(x) => Console.printLine("${x.equiId} ${Int32.toString(List.length(x.classifications))} classifications")
        case Err(msg) => Console.printLine("Error: " + System/Error.toString(msg))
    }



def tableNames(): TableNames = 
    { simpleEqui            = "df_equi"
    , downloadfileMltxt     = "df_eqmltxt"
    , downloadfileClassequi = "df_classequi"
    , downloadfileValuaequi = "df_valuaequi"
    , classFactsMembers     = "cf_members"
    , classFactsCharDefs    = "cf_char_defs"
    }

def build1(equiId: String): DbMonad[S4Equipment] = 
    use BasicDb/DbMonad.{return, flatMap}; 
    use AssetLib/S4/Simple/EquipmentBuilder.{cachePreparedStatements, buildS4Equipment};
    let* pstmts     = cachePreparedStatements(tableNames());
    let* ans        = buildS4Equipment(pstmts, equiId);
    return(ans)

    

