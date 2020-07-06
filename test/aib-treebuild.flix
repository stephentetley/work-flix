
use AssetLib/Aib/FileReaders/TreeExport/TransposeRaw.{transposeRawInput, generateHtml};
   

@test
def main(): Result[Unit, System.Error] & Impure = 
    use Result.flatMap;
    let src = "G:/work/Projects/assets/capital_schemes/otl07/otley_stw_ai2_export.csv";
    let csvdest = "G:/work/Projects/assets/capital_schemes/otl07/otley_stw_ai2_export_TREE2.csv";
    let htmldest = "E:/coding/work/work-flix/output/otley_stw_ai2_export.html";
    let* _ = transposeRawInput(src, 1, csvdest);
    let* _ = generateHtml(src, 1, htmldest);
    Ok()  
