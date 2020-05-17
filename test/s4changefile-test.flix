use S4Lib/ChangeFile/Datatypes.{ChangeFile};

// def runOrError(p: TextParser.Parser[a], f: a -> String, inp: String): String = 
//     match TextParser.run(p, inp) { 
//         case Ok(a) => f(a)
//         case Err(e) => "*** ERROR:" + TextParser/Error.showParserError(e)
//     }


@test
def test01(): Result[ChangeFile, String] & Impure = 
    use S4Lib/ChangeFile/Parser.{parseChangeFile};
    let src = "G:/work/Projects/assets/asset_patch/file_download_edm/car36_outstation_valuaequi.txt";
    parseChangeFile(src)
        

