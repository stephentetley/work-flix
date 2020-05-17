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
        

@test
def test02(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use S4Lib/ChangeFile/Parser.{parseChangeFile};
    use S4Lib/ChangeFile/ExportCsv.{exportCsv};
    let src = "G:/work/Projects/assets/asset_patch/file_download_edm/car36_outstation_valuaequi.txt";
    let dest = "G:/work/Projects/assets/asset_patch/file_download_edm/car36_outstation_valuaequi_output.csv";
    let* x = parseChangeFile(src);
    exportCsv(x, dest)

