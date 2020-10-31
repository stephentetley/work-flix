use AssetLib/S4/FileIO/ZTable/ExportDb.{ZTableSourcePaths};
use AutoLifting/TypeMapping.TypeAnswer;
use AutoLifting/Datatypes.EquiWorkItem;


def main(): Unit & Impure = 
    match mainResult() {
        case Ok() => Console.printLine("Done.")
        case Err(msg) => Console.printLine("Error: " + System/Error.toString(msg))
    }

def ztableSourcePaths(): ZTableSourcePaths = 
    { eqobjlPath    = System/FilePath.new("G:/work/assets/facts/ztables/ztable_eqobjl.txt")
    , flocdesPath   = System/FilePath.new("G:/work/assets/facts/ztables/ztable_flocdes.txt")
    , floobjlPath   = System/FilePath.new("G:/work/assets/facts/ztables/ztable_floobjl.txt")
    , manufPath     = System/FilePath.new("G:/work/assets/facts/ztables/ztable_manuf.txt")
    , objPath       = System/FilePath.new("G:/work/assets/facts/ztables/ztable_obj.txt")
    }

def classFacts(): System.FilePath = System/FilePath.new("G:/work/assets/facts/equi-class-export.txt")

def mainResult(): Result[Unit, System.Error] & Impure = 
    use Result.{flatMap};
    use BasicDb/DbMonad.{runSQLite};    
    use AssetLib/S4/Simple/EquiDownloadBuilder.{setupFacts, buildS4EquipmentList};
    let dbtempFile          = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_temp.sqlite");
    let sources = 
        { equiFile          = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_equi_file_download.txt")
        , classFile         = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_equiclass_file_download.txt")
        , charFile          = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_equichar_file_download.txt")
        , mltextFile        = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo_eqmltxt_file_download.txt")
        };
    let* _  = runSQLite(setupFacts(classFacts(), ztableSourcePaths()), dbtempFile);
    let* xs = runSQLite(buildS4EquipmentList(sources), dbtempFile);
    let _   = List.foreach(x -> Console.printLine("${x.equiId} ${Int32.toString(List.length(x.classifications))} classifications"), xs);
    Ok()

