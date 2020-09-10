use System.Error.{Generic};

use AssetLib/S4/FileIO/ClassList/Raw/ExportDb.{parseFlocClassList, parseEquiClassList, outputDb};



def main(): Result[Unit, System.Error] & Impure =  
    use Result.flatMap;
    let* xs = parseFlocClassList(System/FilePath.new("G:/work/assets/facts/floc-class-export.txt"), Text/Charset.iso_8859_1());
    let* _  = outputDb("floc", xs, System/FilePath.new("G:/work/assets/facts/floc_characteristics.sqlite"));
    let* ys = parseEquiClassList(System/FilePath.new("G:/work/assets/facts/equi-class-export.txt"), Text/Charset.iso_8859_1());
    let* _  = outputDb("equi", ys, System/FilePath.new("G:/work/assets/facts/equi_characteristics.sqlite"));
    Ok()
