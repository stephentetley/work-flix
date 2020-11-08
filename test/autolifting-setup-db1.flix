
use AssetLib/S4/FileIO/ZTable/ExportDb.ZTableSourcePaths;
use AutoLifting/SetupDb.MappingTablePaths;

def main(): Unit & Impure = 
    let outpath = System/FilePath.new("G:/work/assets/lifting-equipment-reports/db1.sqlite");
    Console.printLine("Running...");
    match mainHelper(outpath) {
        case Ok() => Console.printLine("Done.")
        case Err(msg) => Console.printLine("Error: " + System/Error.toString(msg))
    }

def mainHelper(outpath: System.FilePath): Result[Unit, System.Error] & Impure = 
    use BasicDb/DbMonad.{runSQLite};
    runSQLite(AutoLifting/SetupDb.setupStaticTables(equiClassFacts(), ztableSourcePaths(), mappingTablePaths()), outpath)


def equiClassFacts(): System.FilePath = System/FilePath.new("G:/work/assets/facts/equi-class-export.txt")

def ztableSourcePaths(): ZTableSourcePaths = 
    { eqobjlPath    = System/FilePath.new("G:/work/assets/facts/ztables/ztable_eqobjl.txt")
    , flocdesPath   = System/FilePath.new("G:/work/assets/facts/ztables/ztable_flocdes.txt")
    , floobjlPath   = System/FilePath.new("G:/work/assets/facts/ztables/ztable_floobjl.txt")
    , manufPath     = System/FilePath.new("G:/work/assets/facts/ztables/ztable_manuf.txt")
    , objPath       = System/FilePath.new("G:/work/assets/facts/ztables/ztable_obj.txt")
    }

def mappingTablePaths(): MappingTablePaths = 
    { siteMappingPath           = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx")
    , typeMappingPath           = System/FilePath.new("G:/work/assets/lifting-equipment-reports/01.lifting_equipment_types.xlsx")
    , workingLoadMappingPath    = System/FilePath.new("G:/work/assets/lifting-equipment-reports/02.working_load_fields.xlsx")
    }



