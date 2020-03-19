@test
def memoLine01[r](): #{ MemoLine | r } & Impure =
    let src = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\ai2_outstations_dump_2020_03_19.csv";
    let r1 = CsvLoader.importMemoLines(src);
    match r1 { 
        case Err(msg) => { Console.printLine(msg); #{ } }
        case Ok(relns) => solve relns
    }

/// A "cell printer" for the body of Answer.
def answerCells(src: (String, String, String)): Array[String] & Impure = 
    let (x,y,z) = src;
    [x,y,z]


def memoQuery(srcpath: String, patt: String, outpath: String): Unit & Impure = 
    let headers = ["PLI Code", "Common Name", "Memo Text"];
    let buildStep = CsvExport.makeBuildStep(answerCells); 
    match CsvLoader.loadAll(srcpath) { 
        case Err(msg) => Console.printLine(msg)
        case Ok(relns) => 
            { fold Answer CsvExport.emptyCsvBuilder() buildStep (solve relns <+> MemoLine.memoMatch(patt)) }
                |> CsvExport.outputCsv(outpath, headers);
            Console.printLine("Wrote: " + outpath)
    }

@test
def main01(): Unit & Impure = 
    let src = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\ai2_outstations_dump_2020_03_19.csv";
    let patt = ".*S3985.*";
    let dest = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\results_rtu_outstations_S3985.csv";
    memoQuery(src, patt, dest)

@test
def temp01(): Bool = 
    let src = "Upgraded on scheme S3953 RTU Asset Replacement (2017) ";
    let patt = ".*S39.*";
    String.matches(src, patt)