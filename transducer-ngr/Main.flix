

def paths1(): SourceFiles = 
    { equipmentList     = "G:\work\Projects\edm2\march-2020-sync\ai2_ultrasonics_dump_2020_03_27_with_ngr.csv"
    , siteList          = "G:\work\Projects\edm2\march-2020-sync\all_sites_in_order.csv"
    }


@test
def main01[r](): #{ SiteListInfo, EquipmentInfo | r } & Impure = 
    match TransducerNgr/CsvLoader.loadAll(paths1()) {
        case Err(_) => #{ }
        case Ok(relns) => relns
    }

@test
def test01[r](): #{ SiteListInfo | r } & Impure = 
    let siteList          = "G:\work\Projects\edm2\march-2020-sync\all_sites_in_order.csv";
    match TransducerNgr/CsvLoader.importSiteListInfo(siteList) {
        case Err(_) => #{ }
        case Ok(relns) => solve relns
    }