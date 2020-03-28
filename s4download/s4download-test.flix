def runOrError(p: TextParser.Parser[a], f: a -> String, inp: String): String = 
    match TextParser.run(p, inp) { 
        case Ok(a) => f(a)
        case Err(e) => "*** ERROR:" + TextParser.showParserError(e)
    }


@test
def test01(): Result[S4Download/Parser.DownloadHeader, String] & Impure = 
    let src = 
        "G:\work\Projects\assets\asset_patch\file_download_edm\car36_outstation_valuaequi.txt" |> FilePath.new;
    match TextParser.parseFile(S4Download/Parser.pHeader(), src, Charset.utf_8() ) { 
        case Err(e) => Err(TextParser.showParserError(e))
        case Ok(a) => Ok(a)
    }
        

@test
def test02(): Result[S4Download/Parser.DownloadFile, String] & Impure = 
    let src = 
        "G:\work\Projects\assets\asset_patch\file_download_edm\car36_outstation_valuaequi.txt" |> FilePath.new;
    match TextParser.parseFile(S4Download/Parser.pDownload(), src, Charset.utf_8() ) { 
        case Err(e) => Err(TextParser.showParserError(e))
        case Ok(a) => Ok(a)
    }


@test
def test03(): Unit & Impure = 
    let src = 
        "G:\work\Projects\assets\asset_patch\file_download_edm\LSTN_RELAY_1_FUNCTION_valuaequi.txt" |> FilePath.new;
    match TextParser.parseFile(S4Download/Parser.pDownload(), src, Charset.utf_8() ) { 
        case Err(e) => Console.printLine(TextParser.showParserError(e))
        case Ok(a) => {
            let rows = S4Download.makeRows(a);
            List.foreach(S4Download.getValue("CHARID") >> Console.printLine, rows)
        }
    }


@test
def test04(): Unit & Impure = 
    let src = 
        "G:\work\Projects\assets\asset_patch\file_download_edm\LSTN_RELAY_1_FUNCTION_valuaequi.txt" |> FilePath.new;
    match TextParser.parseFile(S4Download/Parser.extractColumnHeadings(), src, Charset.utf_8() ) { 
        case Err(e) => Console.printLine(TextParser.showParserError(e))
        case Ok(xs) => {
            List.foreach(Console.printLine, xs)
        }
    }


@test
def download01(): String = 
    runOrError(S4Download/Parser.download(), x -> x, "* Download")

@test
def dataModel01(): String = 
    runOrError(S4Download/Parser.dataModel(), x -> x, "* Data Model: U1")

@test
def entityType01(): String = 
    runOrError(S4Download/Parser.entityType(), x -> x, "* Entity Type: EQUI")

@test
def variant01(): String = 
    runOrError(S4Download/Parser.variant(), x -> x, "* Variant:")

@test
def user01(): String = 
    runOrError(S4Download/Parser.user(), x -> x, "* User: TETLEYS")

@test
def dateTime01(): String = 
    let conv = p -> { let (x,y) = p; x + ", " + y } ;
    runOrError(S4Download/Parser.dateTime(),  conv, "* Date: 20200306 / Time:090808")
