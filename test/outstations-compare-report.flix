use BasicDb.DbMonad;

use EquiCompare/Report/Relations.{AibEquipment, S4Equipment, SiteMap};
use EquiCompare/Report/Compare.{Synced, NotMigrated, Orphaned};

def main(_args: Array[String]): Int32 & Impure = 
    use BasicDb/DbMonad.{runSQLite};
    Console.printLine("Running...");
    let dppath = System/FilePath.new("G:/work/assets/outstations/outstations.sqlite");
    match runSQLite(getRecords(), dppath) {
        case Ok(db) => report(db)
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }


def report[r](db: #{Synced, NotMigrated, Orphaned, AibEquipment, S4Equipment, SiteMap | r}): Int32 & Impure = 
    use EquiCompare/Report/Compare.{synced, notMigrated, orphaned};
    let ans1 = solve (db <+> synced());
    Console.printLine(unsafeToString(project Synced ans1));
    let ans2 = solve (db <+> notMigrated());
    Console.printLine(unsafeToString(project NotMigrated ans2));
    let ans3 = solve (db <+> orphaned());
    Console.printLine(unsafeToString(project Orphaned ans3));
    0


def getRecords[r](): DbMonad[#{AibEquipment, S4Equipment, SiteMap | r }] = 
    use BasicDb/DbMonad.{flatMap, return};
    let* x  = EquiCompare/Report/Loader.getAibEquipment("aib_equipment");
    let* y  = EquiCompare/Report/Loader.getS4Equipment("s4_equipment");    
    let* z  = EquiCompare/Report/Loader.getSiteMap("lookup_site");
    return(x <+> y <+> z)

