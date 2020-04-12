
@test
def s4EquiLoad01[r](): #{ S4EquiInfo | r } & Impure =
    let src1 = "G:\work\Projects\assets\asset_patch\file_download_edm\equi_download_objtype=NETW.csv";
    let r1 = EquipmentCompare/CsvLoader.importS4EquiInfo(src1);
    match r1 { 
        case Err(msg) => { Console.printLine(msg); #{ } }
        case Ok(relns) => solve relns
    }

@test
def ai2EquipmentLoad01[r](): #{ AI2EquipmentInfo | r } & Impure =
    let src1 = "G:\work\Projects\assets\asset_patch\file_download_edm\ai2_outstations.csv";
    let r1 = EquipmentCompare/CsvLoader.importAI2EquipmentInfo(src1);
    match r1 { 
        case Err(msg) => { Console.printLine(msg); #{ } }
        case Ok(relns) => solve relns
    }

@test
def siteMappingLoad01[r](): #{ SiteMapping | r } & Impure =
    let src1 = "G:\work\Projects\assets\asset_patch\file_download_edm\ai_to_s4_sites.csv";
    let r1 = EquipmentCompare/CsvLoader.importSiteMapping(src1);
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
    EquipmentCompare.siteMap("MANCHESTER ROAD/CSO", relns)

pub def siteMap[r](name: String): #{ SiteMapAnswer | r } & Impure =
    let relns = siteMappingLoad01();
    EquipmentCompare.siteMap(name, relns)


@test
def equipmentMatches01(): Unit & Impure = 
    let paths = 
        { s4Equipment   = "G:\work\Projects\assets\asset_patch\file_download_edm\equi_download_objtype=NETW.csv"
        , aiOutstations = "G:\work\Projects\assets\asset_patch\file_download_edm\ai2_outstations.csv"
        , siteMapping   = "G:\work\Projects\assets\asset_patch\file_download_edm\ai_to_s4_sites.csv"
        };
    let dest = "G:\work\Projects\assets\asset_patch\file_download_edm\results_equi_matches_001.csv";
    match EquipmentCompare/CsvLoader.loadAll(paths) { 
        case Err(msg) => Console.printLine(msg)
        case Ok(relns) => 
            let ans = solve relns <+> EquipmentCompare.equipmentMatch() ;
            EquipmentCompare.csvWriteEquipment(dest, ans);
            ()
    }

/// A "cell printer" for the body of NoS4.
def noS4Cells(src: (String,String)): Array[String] & Impure = 
    let (x,y) = src;
    [x,y]




pub def noS4(paths: SourceFiles, outfile: String): Unit & Impure = 
    let headers = ["ai_name", "s4_code"];
    let buildStep = FactIO/CsvExport.makeBuildStep(noS4Cells); 
    match EquipmentCompare/CsvLoader.loadAll(paths) { 
        case Err(msg) => Console.printLine(msg)
        case Ok(relns) => {
            { fold NoS4 FactIO/CsvExport.emptyCsvBuilder() buildStep (solve relns <+> EquipmentCompare.noS4()) }
                |> FactIO/CsvExport.outputCsv(outfile, headers);
            Console.printLine("Wrote: " + outfile)
        }
    }

@test
def noS4_001() : Unit & Impure = 
    let srcfiles = 
        { s4Equipment   = "G:\work\Projects\assets\asset_patch\file_download_edm\equi_download_objtype=NETW.csv"
        , aiOutstations = "G:\work\Projects\assets\asset_patch\file_download_edm\ai2_outstations.csv"
        , siteMapping   = "G:\work\Projects\assets\asset_patch\file_download_edm\ai_to_s4_sites.csv"
        };
    let dest = "G:\work\Projects\assets\asset_patch\file_download_edm\results_nos4_001.csv";
    noS4(srcfiles, dest)

@test
def noS4_002() : Unit & Impure = 
    let srcfiles = 
        { s4Equipment   = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\file_download-prod-objtype=NETW.csv"
        , aiOutstations = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\ai2_outstations_dump_2020_03_19.csv"
        , siteMapping   = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\ai_to_s4_sites.csv"
        };
    let dest = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\results_nos4_002_prod_netw.csv";
    noS4(srcfiles, dest)


@test
def noS4_003() : Unit & Impure = 
    let srcfiles = 
        { s4Equipment   = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\file_download-prod-objtype=LSTN.csv"
        , aiOutstations = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\ai2_ultrasonics_dump_2020_03_19.csv"
        , siteMapping   = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\ai_to_s4_sites.csv"
        };
    let dest = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\results_nos4_002_prod_lstn.csv";
    noS4(srcfiles, dest)
