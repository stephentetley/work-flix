use BasicDb.DbMonad;

use EquiCompare/Report/Relations.{AibEquipment, S4Equipment, SiteMap};
use EquiCompare/Report/Compare.{Synced, NotMigrated, Orphaned};

def main(_args: Array[String]): Int32 & Impure = 
    use EquiCompare/Report/Compare.{synced, notMigrated, orphaned};
    println("Running...");
    let dppath = System/FilePath.new("G:/work/assets/outstations/outstations.sqlite");
    let outpath = System/FilePath.new("G:/work/assets/outstations/outstations-report.xlsx");
    match main1(dppath, outpath) {
        case Ok() => {println("Wrote: ${outpath}"); 0}
        case Err(msg) => {println("Error: ${msg}"); 1}
        
    }

def main1(dbpath: System.FilePath, outpath: System.FilePath): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use EquiCompare/Report/Compare.{synced, notMigrated, orphaned};
    let* db     = BasicDb/DbMonad.runSQLite(getRecords(), dbpath);
    let ans     = solve (db <+> synced() <+> notMigrated() <+> orphaned());
    let* _      = EquiCompare/Report/XlsxWriter.writeReport(ans, outpath);
    Ok()


def getRecords[r](): DbMonad[#{AibEquipment, S4Equipment, SiteMap | r}] = 
    use BasicDb/DbMonad.{flatMap, point};
    let* x  = EquiCompare/Report/Loader.getAibEquipment("aib_equipment");
    let* y  = EquiCompare/Report/Loader.getS4Equipment("s4_equipment");    
    let* z  = EquiCompare/Report/Loader.getSiteMap("lookup_site");
    point(x <+> y <+> z)

