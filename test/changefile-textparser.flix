use System.Error.{Generic};

use AssetLib/S4/FileIO/ChangeFile/Datatypes.{ChangeFile};
use AssetLib/S4/FileIO/ChangeFile/Parser.{parseFile};
use AssetLib/S4/FileIO/ChangeFile/CsvExport.{exportCsv};

// def runOrError(p: TextParser.Parser[a], f: a -> String, inp: String): String = 
//     match TextParser.run(p, inp) { 
//         case Ok(a) => f(a)
//         case Err(e) => "*** ERROR:" + TextParser/Error.showParserError(e)
//     }

        

@test
def main(): Result[Unit, System.Error] & Impure = 
    use Result.flatMap;
    let src = System/FilePath.new("G:/work/Projects/assets/tree-build/goo04-wsp-floc-file_download.txt");
    let dest = System/FilePath.new("G:/work/Projects/assets/tree-build/goo04-wsp-floc-file_download_export.csv");
    let* x = parseFile(src);
    let* _ = exportCsv(x, dest);
    Ok()

// @test
// def tree01(): Result[ChangeFile, System.Error] & Impure = 
//     use AssetLib/S4/FileReaders/ChangeFile/Parser.{parseFile};
//     let src = "G:/work/Projects/assets/tree-build/goo04-wsp-floc-file_download.txt";
//     parseFile(src)

