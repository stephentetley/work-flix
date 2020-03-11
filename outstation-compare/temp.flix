
@test
def s4EquiLoad01[r](): #{ S4EquiInfo | r } & Impure =
    let src1 = "G:\work\Projects\assets\asset_patch\file_download_edm\equi_download_objtype=NETW.csv";
    let r1 = CsvLoader.importS4EquiInfo(src1);
    match r1 { 
        case Err(msg) => { Console.printLine(msg); #{ } }
        case Ok(relns) => solve relns
    }

@test
def ai2OutstationLoad01[r](): #{ AI2OutstationInfo | r } & Impure =
    let src1 = "G:\work\Projects\assets\asset_patch\file_download_edm\ai2_outstations.csv";
    let r1 = CsvLoader.importAI2OutstationInfo(src1);
    match r1 { 
        case Err(msg) => { Console.printLine(msg); #{ } }
        case Ok(relns) => solve relns
    }

@test
def siteMappingLoad01[r](): #{ SiteMapping | r } & Impure =
    let src1 = "G:\work\Projects\assets\asset_patch\file_download_edm\ai_to_s4_sites.csv";
    let r1 = CsvLoader.importSiteMapping(src1);
    match r1 { 
        case Err(msg) => { Console.printLine(msg); #{ } }
        case Ok(relns) => solve relns
    }

// def count[a](_: a, acc:Int32): Int32 = acc + 1

@test
def siteMappingLoad02(): Int32 & Impure =
    let relns = siteMappingLoad01();
    fold SiteMapping 0 ((_,x) -> x+1) relns

@test
def siteMapping01[r](): #{ SiteMapAnswer | r } & Impure =
    let relns = siteMappingLoad01();
    Compare.siteMap("MANCHESTER ROAD/CSO", relns)

pub def siteMap[r](name: String): #{ SiteMapAnswer | r } & Impure =
    let relns = siteMappingLoad01();
    Compare.siteMap(name, relns)


@test
def telemetryMatches01[r](): #{ Telemetry, SiteMapping, S4EquiInfo, AI2OutstationInfo | r } & Impure = 
    let paths = 
        { s4Equipment   = "G:\work\Projects\assets\asset_patch\file_download_edm\equi_download_objtype=NETW.csv"
        , aiOutstations = "G:\work\Projects\assets\asset_patch\file_download_edm\ai2_outstations.csv"
        , siteMapping   = "G:\work\Projects\assets\asset_patch\file_download_edm\ai_to_s4_sites.csv"
        };
    match CsvLoader.loadAll(paths) { 
        case Err(msg) => { Console.printLine(msg); #{ } }
        case Ok(relns) => 
        project Telemetry (solve relns <+> Compare.telemetryMatch())
    }


@test
def noS4[r](): #{ NoS4 | r } & Impure = 
    let paths = 
        { s4Equipment   = "G:\work\Projects\assets\asset_patch\file_download_edm\equi_download_objtype=NETW.csv"
        , aiOutstations = "G:\work\Projects\assets\asset_patch\file_download_edm\ai2_outstations.csv"
        , siteMapping   = "G:\work\Projects\assets\asset_patch\file_download_edm\ai_to_s4_sites.csv"
        };
    match CsvLoader.loadAll(paths) { 
        case Err(msg) => { Console.printLine(msg); #{ } }
        case Ok(relns) => 
        project NoS4 (solve relns <+> Compare.noS4())
    }

