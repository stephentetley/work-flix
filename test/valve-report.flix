use BasicDb.DbMonad;
use AssetLib/S4Lite/CreateNew/Datatypes.{S4Equipment};
use AssetLib/S4Lite/CreateNew/EquipmentBuilder.{TableNames};



def main(): Unit & Impure =  
    let dbpath          = System/FilePath.new("G:/work/assets/capital_schemes/valves1.sqlite");
    let worklistPaths =     
        { export1           = System/FilePath.new("G:/work/assets/capital_schemes/lee22/leeming-bar-aib-export.xlsx")
        };        
    Console.printLine("Running...");
    match BasicDb/DbMonad.runSQLite(setupAibFacts(worklistPaths.export1), dbpath) {
        case Ok() => Console.printLine("Good see ${dbpath}")
        case Err(msg) => Console.printLine("Error: ${msg}")
    }



def setupAibFacts(export1: System.FilePath): DbMonad[Unit] = 
    use BasicDb/DbMonad.{return, flatMap};
    let* _ = ValveReport/SetupDb/TextFact.initTextFactTable("aib_text_facts");
    let* _ = ValveReport/SetupDb/CommonFacts.storeCommonFacts("aib_text_facts", export1);
    return()