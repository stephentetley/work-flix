use System.Error.{Generic};

use AssetLib/S4/FileIO/EntityFile/Datatypes.{EntityFile};
use AssetLib/S4/FileIO/EntityFile/Parser.{parseFile};
use AssetLib/S4/FileIO/EntityFile/ExportCsv.{exportCsv};
use AssetLib/S4/FileIO/EntityFile/ExportDb.{exportDb};


@test
def main(): Result[Unit, System.Error] & Impure = 
    use Result.flatMap;
    let src = System/FilePath.new("G:/work/Projects/assets/tree-build/goo04-wsp-floc-file_download.txt");
    let dest = System/FilePath.new("G:/work/Projects/assets/tree-build/goo04-wsp-floc-file_download_export.csv");
    let* x = parseFile(src);
    let* _ = exportCsv(x, dest);
    Ok()

