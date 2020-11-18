use BasicDb.DbMonad;
use AssetLib/S4/Simple/Datatypes.{S4Equipment};
use AssetLib/S4/Simple/EquipmentBuilder.{TableNames};


def main(): Unit & Impure = 
    use BasicDb/DbMonad.{runSQLite}; 
    use AutoLifting/Common/ReportMonad.{runReportMonad};  
    let dbpath          = System/FilePath.new("G:/work/assets/lifting-equipment-reports/db1.sqlite");
    let uxlTemplate     = System/FilePath.new("G:/work/assets/lifting-equipment-reports/MMOP_uXL.xlsx");
    let uxlOutput       = System/FilePath.new("G:/work/assets/lifting-equipment-reports/NewUxl1.xlsx");
    match runSQLite(buildExisting("101000608"), dbpath) {
        case Ok(x) => Console.printLine("${x.equiId} ${Int32.toString(List.length(x.classifications))} classifications")
        case Err(msg) => Console.printLine("Error: " + System/Error.toString(msg))
    };
    match runSQLite(buildNew("PLI00773985", "DEIGHTON/STW/STATUTORY/LIFTING EQUIPMENT/YW29301 CHAIN BLOCK/EQUIPMENT: CHAIN BEAM HOIST-HAND"), dbpath) {
        case Ok(x) => Console.printLine("${x.equiId} ${Int32.toString(List.length(x.classifications))} classifications")
        case Err(msg) => Console.printLine("Error: " + System/Error.toString(msg))
    };
    match runReportMonad(AutoLifting/NewGenerateReport.makeReport("Lifting Update", uxlTemplate, uxlOutput), dbpath) {
        case Ok() => Console.printLine("Good - see ${System/FilePath.toString(uxlOutput)}")
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

def buildExisting(s4EquiId: String): DbMonad[S4Equipment] = 
    use BasicDb/DbMonad.{return, flatMap}; 
    use AssetLib/S4/Simple/EquipmentBuilder.{cachePreparedStatements, buildS4Equipment};
    let* pstmts     = cachePreparedStatements(tableNames());
    let* ans        = buildS4Equipment(pstmts, s4EquiId);
    return(ans)

def buildNew(reference: String, commonName: String): DbMonad[S4Equipment] = 
    use BasicDb/DbMonad.{return, flatMap}; 
    use AutoLifting/Build/ChildNew.{cachePreparedStatements, childNew};
    let* pstmts     = cachePreparedStatements();
    let* ans        = childNew(pstmts, reference, commonName, "$1001");
    return(ans)    

    

