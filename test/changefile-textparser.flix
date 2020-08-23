use System.Error.{Generic};

use AssetLib/S4/FileIO/ChangeFile/Datatypes.{ChangeFile};
use AssetLib/S4/FileIO/ChangeFile/Parser.{parseFile};
use AssetLib/S4/FileIO/ChangeFile/ExportCsv.{exportCsv};
use AssetLib/S4/FileIO/ChangeFile/ExportDb.{exportDb};


@test
def main(): Result[Unit, System.Error] & Impure = 
    use Result.flatMap;
    let src = System/FilePath.new("G:/work/Projects/assets/tree-build/goo04-wsp-floc-file_download.txt");
    let dest = System/FilePath.new("G:/work/Projects/assets/tree-build/goo04-wsp-floc-file_download_export.csv");
    let* x = parseFile(src);
    let* _ = exportCsv(x, dest);
    Ok()

