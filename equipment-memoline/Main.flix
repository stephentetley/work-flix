@test
def memoLine01[r](): #{ MemoLine | r } & Impure =
    let src = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\ai2_outstations_dump_2020_03_19.csv";
    let r1 = CsvLoader.importMemoLines(src);
    match r1 { 
        case Err(msg) => { Console.printLine(msg); #{ } }
        case Ok(relns) => solve relns
    }

/// A "cell printer" for the body of Answer.
def answerCells(src: (String, String, String, Int32, String)): Array[String] & Impure = 
    let (x1,x2,x3,x4,x5) = src;
    [x1, x2, x3, Int32.toString(x4), x5]


def memoQuery(srcpath: String, patt: String, outpath: String): Unit & Impure = 
    let headers = ["PLI Code", "Common Name", "Memo Text", "Year Installed", "Serial No"];
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
    let src = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\ai2_outstations_dump_2020_03_20.csv";
    let patt = ".*S39(53|85).*";
    let dest = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\results_rtu_outstations_S39XX_2020_03_20.csv";
    memoQuery(src, patt, dest)

@test
def main02(): Unit & Impure = 
    let src = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\ai2_outstations_dump_2020_03_20.csv";
    let patt = ".*RTU.*";
    let dest = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\results_rtu_outstations_RTU_2020_03_20.csv";
    memoQuery(src, patt, dest)


@test
def main03(): Unit & Impure = 
    let src = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\ai2_ultrasonics_dump_2020_03_20.csv";
    let patt = ".*T0975.*";
    let dest = "G:\work\Projects\assets\asset_patch\equipment-compare-march2020\results_ultrasonics_EDM2_2020_03_20.csv";
    memoQuery(src, patt, dest)


// String.matches("Upgraded on scheme S3985 RTU Asset Replacement (2019) ", ".*S39(53|85).*")

@test
def temp01(): Bool = 
    let s1 = "Upgraded on scheme S3953 RTU Asset Replacement (2017) ";
    let s2 = "Upgraded on scheme S3985 RTU Asset Replacement (2019) ";
    let patt = ".*S39(53|85).*";
    String.matches(s1, patt) && String.matches(s2, patt)

@test
def temp02(): Int32 & Impure = 
    let patt = Regex.compile("(?<year>\d{4})");
    let m = Regex.matcher(patt, "13/08/2015 00:00");
    if (Regex.find(m)) {
        Regex.namedGroup(m, "year") |> Int32.fromString |> x -> Result.getWithDefault(x, 0)
    } else 0




