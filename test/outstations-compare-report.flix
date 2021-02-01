use BasicDb.DbMonad;

use EquiCompare/Report/Relations.{AibEquipment, S4Equipment, SiteMap};

def main(_args: Array[String]): Int32 & Impure = 
    use BasicDb/DbMonad.{runSQLite};
    Console.printLine("Running...");
    let dppath = System/FilePath.new("G:/work/assets/outstations/outstations.sqlite");
    match runSQLite(getRecords(), dppath) {
        case Ok(r) => {Console.printLine(unsafeToString(project SiteMap r)); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }
    

def getRecords[r](): DbMonad[#{AibEquipment, S4Equipment, SiteMap | r }] = 
    use BasicDb/DbMonad.{flatMap, return};
    let* x  = EquiCompare/Report/Loader.getAibEquipment("aib_equipment");
    let* y  = EquiCompare/Report/Loader.getS4Equipment("s4_equipment");    
    let* z  = EquiCompare/Report/Loader.getSiteMap("lookup_site");
    return(x <+> y <+> z)

