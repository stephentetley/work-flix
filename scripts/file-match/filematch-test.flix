pub def result1(a: Result[reln,e]): reln = match a { 
    case Err(_) => #{ } 
    case Ok(reln) => reln
}

pub def src() : Str = "G:\work\Projects\rtu\mk5-mmims\diffs\temp.txt"


@test
def exists01(): Result[Bool, String] & Impure = 
    match Path.exists(Path.new(src())) {
        case Err(_) => Err("IOError")
        case Ok(a) => Ok(a)
    }


@test
def readLines01(): Result[Bool, String] & Impure = 
    match File.readFile(FilePath.new(src()), Charset.utf_16le()) {
        case Err(_) => Err("IOError")
        case Ok(_) => Ok(true)
    }

@test
def pFolder01(): Result[String, String] = 
    let inp = "d-----       13/02/2020     08:49                ABBEY LANE HULL_SPS                                                                                                                                                       ";
    TextParser.runs(FileMatch/DirListing.pFolder(), inp) 
        |> Result.map(x -> x.name)



@test
def parse01(): Result[String, String] = 
    let inp = "d-----       13/02/2020     08:49                ABBEY LANE HULL_SPS                                                                                                                                                       ";
    TextParser.runs(TextParser.horizon(13), inp) 

@test
def parse02[r](): Result[ #{ SWS | r }, String] = 
    let inp = "d-----       13/02/2020     08:49                ABBEY LANE HULL_SPS                     ";
    TextParser.runs(FileMatch.parseSWS(), inp) 
        


@test
def parse03[r](): #{ SWS | r } = 
    let inp = "d-----       13/02/2020     08:49                ABBEY LANE HULL_SPS                     ";
    match TextParser.runs(FileMatch.parseSWS(), inp) { 
        case Err(msg) => Err(msg)
        case Ok(reln) => Ok(solve reln)
    } |> result1 
        


@test
def ignore01(): Result[Option[String], String] = 
    let inp = "";
    TextParser.runs(FileMatch/DirListing.ignoreLine(), inp) 
        
@test
def sws01[r](): #{ SWS | r } & Impure = 
    FileMatch.importSWS(src(), Charset.utf_16le())

        
@test
def sws02[r](): #{ SWS | r } & Impure = 
    FileMatch.importSWS("G:\work\Projects\rtu\mk5-mmims\diffs\sws.txt", Charset.utf_16le())




pub def main1() : #{ Todo | r } & Impure = 
    let sws = FileMatch.importSWS("G:\work\Projects\rtu\mk5-mmims\diffs\sws.txt", Charset.utf_16le());
    let b1 = FileMatch.importBatch("G:\work\Projects\rtu\mk5-mmims\diffs\batch1.txt", Charset.utf_16le(), "batch1");
    let b2 = FileMatch.importBatch("G:\work\Projects\rtu\mk5-mmims\diffs\batch2.txt", Charset.utf_16le(), "batch2");
    let b3 = FileMatch.importBatch("G:\work\Projects\rtu\mk5-mmims\diffs\batch3.txt", Charset.utf_16le(), "batch3");

    project Todo (solve sws <+> b1 <+> b2 <+> b3 <+> FileMatch.fileMatchRules())

