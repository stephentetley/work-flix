use BasicDb.DbMonad;

use EquiCompare/Report/Loader.{EquiRow, SiteMapRow};

def main(_args: Array[String]): Int32 & Impure = 
    use BasicDb/DbMonad.{runSQLite};
    Console.printLine("Running...");
    let dppath = System/FilePath.new("G:/work/assets/outstations/outstations.sqlite");
    match runSQLite(getRecords(), dppath) {
        case Ok(r) => {Console.printLine("Read: AI2 ${List.length(r.aibRows)} rows, S4 ${List.length(r.s4Rows)} rows, Mapping ${List.length(r.mappingRows)} "); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }
    

def getRecords(): DbMonad[{aibRows: List[EquiRow], s4Rows: List[EquiRow], mappingRows: List[SiteMapRow]}] = 
    use BasicDb/DbMonad.{flatMap, return};
    let* xs = EquiCompare/Report/Loader.getAibEquis("aib_equipment");
    let* ys  = EquiCompare/Report/Loader.getS4Equis("s4_equipment");    
    let* zs  = EquiCompare/Report/Loader.getSiteMapping("lookup_site");
    return({aibRows = xs, s4Rows = ys, mappingRows = zs})

