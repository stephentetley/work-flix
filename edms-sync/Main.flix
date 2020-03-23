

def paths1(): SourceFiles = 
    { edmExport         = "G:\work\Projects\edm2\march-2020-sync\edms-edm2-export.csv"
    , csoSpsSurveys     = "G:\work\Projects\edm2\march-2020-sync\facts-cso-sps-surveys.csv"
    , stwSurveys        = "G:\work\Projects\edm2\march-2020-sync\facts-stw-surveys.csv"
    , csoSpsSiteWork    = "G:\work\Projects\edm2\march-2020-sync\facts-cso-sps-sitework.csv"
    , stwSiteWork       = "G:\work\Projects\edm2\march-2020-sync\facts-stw-sitework.csv"
    }

@test
def edms01[r](): #{ Synced | r } & Impure =
    match CsvLoader.loadAll(paths1()) { 
        case Err(msg) => { Console.printLine(msg); #{ } }
        case Ok(relns) => project Synced (solve relns <+> Sync.synced())
    }

@test
def syncable01(): Unit & Impure =
    Sync.syncableQuery(paths1(), "G:\work\Projects\edm2\march-2020-sync\syncable.csv") 
