use System.Error.{Generic};

use AssetLib/S4/FileIO/ClassList/Raw/BuildDb.{parseFlocClassList, parseEquiClassList, outputDb};



def main(): Result[Unit, System.Error] & Impure =  
    use Result.flatMap;
    let* xs = parseFlocClassList(System/FilePath.new("G:/work/Projects/assets/facts/floc-class-export.txt"), Text/Charset.iso_8859_1());
    let* ys = parseEquiClassList(System/FilePath.new("G:/work/Projects/assets/facts/equi-class-export.txt"), Text/Charset.iso_8859_1());
    let* _  = outputDb(xs, ys, System/FilePath.new("G:/work/Projects/assets/facts/characteristics_db.sqlite"));
    Ok()
