use System.Error.{Generic};

use FactIO.JdbcExport;

use AssetLib/S4/FileIO/ClassList/Raw/ExportDb.{parseFlocClassList, parseEquiClassList, outputTables};

pub def main(): Result[Unit, System.Error] & Impure =         
    use FactIO/JdbcExport.{runSQLiteExport};
    runSQLiteExport(buildDb(), System/FilePath.new("G:/work/assets/facts/classfile_characteristics.sqlite"))


def buildDb(): JdbcExport[Unit] =  
    use FactIO/JdbcExport.{return, flatMap, close};
    let* xs     = parseFlocClassList(System/FilePath.new("G:/work/assets/facts/floc-class-export.txt"), Text/Charset.iso_8859_1());
    let* _      = outputTables("floc", xs);
    let* ys     = parseEquiClassList(System/FilePath.new("G:/work/assets/facts/equi-class-export.txt"), Text/Charset.iso_8859_1());
    let* _      = outputTables("equi", ys);
    let* _      = close();
    return()



