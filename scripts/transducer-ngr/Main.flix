

def paths1(): SourceFiles = 
    { equipmentList     = "G:\work\Projects\edm2\march-2020-sync\ai2_ultrasonics_dump_2020_03_27_with_ngr.csv"
    , siteList          = "G:\work\Projects\edm2\march-2020-sync\site_list_with_ngr.csv"
    }


@test
def main01(): Unit & Impure = 
    TransducerNgr.answerQuery(paths1(), "G:\work\Projects\edm2\march-2020-sync\site_list_ngr_results.csv")

@test
def test01[r](): #{ SiteListInfo | r } & Impure = 
    let siteList          = "G:\work\Projects\edm2\march-2020-sync\site_list_with_ngr.csv";
    match TransducerNgr/CsvLoader.importSiteListInfo(siteList) {
        case Err(_) => #{ }
        case Ok(relns) => solve relns
    }