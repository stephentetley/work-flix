
use AssetLib/Aib/FileIO/TreeExport/TransposeRaw.{transposeRawInput, generateHtml};
   

@test
def main(): Result[Unit, System.Error] & Impure = 
    use Result.flatMap;
    let src = System/FilePath.new("G:/work/assets/capital_schemes/otl07/otley_stw_ai2_export.xlsx");
    let csvdest = System/FilePath.new("G:/work/assets/capital_schemes/otl07/otley_stw_ai2_export_TREE2.csv");
    let htmldest = System/FilePath.new("E:/coding/work/work-flix/output/otley_stw_ai2_export.html");
    let* _ = transposeRawInput(src, 1, csvdest);
    let* _ = generateHtml(src, 1, htmldest);
    Ok()  
