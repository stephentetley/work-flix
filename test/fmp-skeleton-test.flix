use AssetLib/AibRel/HierarchicalRelations.{AibSite, AibFloc, AibEquipment};
use AssetLib/S4Rel/Relations.{FlocDatum, FlocCharacteristic, EquiDatum, EquiCharacteristic};
use FmpSkeleton/Main.{main1};

def main(_args: Array[String]): Int32 & Impure =
    Console.printLine("Running...");
    let config = 
        { siteMappingFile   = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx")
        , uxlTemplate       = System/FilePath.new("G:/work/assets/fmp-new-sites/MMOP uXL.xlsx")
        , sourceDir         = System/FilePath.new("G:/work/assets/fmp-new-sites/sites")
        }; 
    match main1(config) {
        case Ok() => {Console.printLine("Okay."); Console.printLine("${AssetLib/S4Rel/Renumber.start()}"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }

