

def paths1(): SourceFiles = 
    { edmExport         = "G:\work\Projects\edm2\march-2020-sync\all-sites-on-edms-2020-03-24.csv"
    , csoSpsSurveys     = "G:\work\Projects\edm2\march-2020-sync\facts-cso-sps-surveys.csv"
    , stwSurveys        = "G:\work\Projects\edm2\march-2020-sync\facts-stw-surveys.csv"
    , csoSpsSiteWork    = "G:\work\Projects\edm2\march-2020-sync\facts-cso-sps-sitework.csv"
    , stwSiteWork       = "G:\work\Projects\edm2\march-2020-sync\facts-stw-sitework.csv"
    , siteList          = "G:\work\Projects\edm2\march-2020-sync\all_sites_in_order.csv"
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

@test
def noSurvey01(): Unit & Impure =
    Sync.noSurveyQuery(paths1(), "G:\work\Projects\edm2\march-2020-sync\no_survey.csv") 

@test
def noSiteWork01(): Unit & Impure =
    Sync.noSiteWorkQuery(paths1(), "G:\work\Projects\edm2\march-2020-sync\no_site_work.csv") 

@test
def siteListStatus01(): Unit & Impure =
    Sync.siteListStatusQuery(paths1(), "G:\work\Projects\edm2\march-2020-sync\site_list_status.csv") 

@test
def edmsStatus01(): Unit & Impure =
    Sync.edmsStatusQuery(paths1(), "G:\work\Projects\edm2\march-2020-sync\edms_status_all_sites.csv") 