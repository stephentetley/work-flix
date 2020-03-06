def runOrError(p: TextParser.Parser[a], f: a -> String, inp: String): String = 
    match TextParser.run(p, inp) { 
        case Ok(a) => f(a)
        case Err(msg) => "*** ERROR:" + msg
    }


@test
def test01(): Result[S4DownloadParser.DownloadHeader, String] & Impure = 
    let src = 
        "G:\work\Projects\assets\asset_patch\file_download_edm\car36_outstation_valuaequi.txt" |> FilePath.new;
    TextParser.parseFile(S4DownloadParser.pHeader(), src, Charset.utf_8() )

@test
def test02(): Result[S4DownloadParser.DownloadFile, String] & Impure = 
    let src = 
        "G:\work\Projects\assets\asset_patch\file_download_edm\car36_outstation_valuaequi.txt" |> FilePath.new;
    TextParser.parseFile(S4DownloadParser.pDownload(), src, Charset.utf_8() )



@test
def download01(): String = 
    runOrError(S4DownloadParser.download(), x -> x, "* Download")

@test
def dataModel01(): String = 
    runOrError(S4DownloadParser.dataModel(), x -> x, "* Data Model: U1")

@test
def entityType01(): String = 
    runOrError(S4DownloadParser.entityType(), x -> x, "* Entity Type: EQUI")

@test
def variant01(): String = 
    runOrError(S4DownloadParser.variant(), x -> x, "* Variant:")

@test
def user01(): String = 
    runOrError(S4DownloadParser.user(), x -> x, "* User: TETLEYS")

@test
def dateTime01(): String = 
    let conv = p -> { let (x,y) = p; x + ", " + y } ;
    runOrError(S4DownloadParser.dateTime(),  conv, "* Date: 20200306 / Time:090808")
