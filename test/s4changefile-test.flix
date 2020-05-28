use System.Error.{Generic};

use AssetLib/S4/ChangeFile/Datatypes.{ChangeFile};

// def runOrError(p: TextParser.Parser[a], f: a -> String, inp: String): String = 
//     match TextParser.run(p, inp) { 
//         case Ok(a) => f(a)
//         case Err(e) => "*** ERROR:" + TextParser/Error.showParserError(e)
//     }


@test
def test01(): Result[ChangeFile, System.Error] & Impure = 
    use AssetLib/S4/ChangeFile/Parser.{parseFile};
    let src = "G:/work/Projects/assets/asset_patch/file_download_edm/car36_outstation_valuaequi.txt";
    parseFile(src)
        

@test
def main(): Result[Unit, System.Error] & Impure = 
    use Result.flatMap;
    use AssetLib/S4/ChangeFile/Parser.{parseFile};
    use AssetLib/S4/ChangeFile/ExportCsv.{exportCsv};
    let src = "G:/work/Projects/assets/tree-build/goo04-wsp-floc-file_download.txt";
    let dest = "G:/work/Projects/assets/tree-build/goo04-wsp-floc-file_download_export.csv";
    let* x = parseFile(src);
    let* _ = exportCsv(x, dest);
    Ok()

@test
def tree01(): Result[ChangeFile, System.Error] & Impure = 
    use AssetLib/S4/ChangeFile/Parser.{parseFile};
    let src = "G:/work/Projects/assets/tree-build/goo04-wsp-floc-file_download.txt";
    parseFile(src)

