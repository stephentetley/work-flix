use BasicDb.DbMonad;
use AssetLib/S4Lite/CreateNew/Datatypes.{S4Equipment};
use AssetLib/S4Lite/CreateNew/EquipmentBuilder.{TableNames};

type alias SourcePaths = 
    { export1: System.FilePath
    , memos: System.FilePath
    }

def main(): Unit & Impure =  
    let dbpath          = System/FilePath.new("G:/work/assets/capital_schemes/valves1.sqlite");
    let sourcePaths =     
        { export1           = System/FilePath.new("G:/work/assets/capital_schemes/lee22/leeming-bar-aib-export.xlsx")
        , memos             = System/FilePath.new("G:/work/assets/capital_schemes/lee22/lee22-valve-memos-export.xlsx")
        };        
    Console.printLine("Running...");
    match BasicDb/DbMonad.runSQLite(setupAibFacts(sourcePaths), dbpath) {
        case Ok() => Console.printLine("Good see ${dbpath}")
        case Err(msg) => Console.printLine("Error: ${msg}")
    }



def setupAibFacts(sources: SourcePaths): DbMonad[Unit] = 
    use BasicDb/DbMonad.{return, flatMap};
    let* _ = AssetLib/AibFacts/SetupDb/TextFact.initTextFactTable("aib_text_facts");
    let* _ = AssetLib/AibFacts/SetupDb/CommonFacts.storeCommonFacts("aib_text_facts", sources.export1);    
    let* _ = AssetLib/AibFacts/SetupDb/MemoLines.storeCommonFacts("aib_text_facts", sources.memos);
    return()