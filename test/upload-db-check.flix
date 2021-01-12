


def main(_: Array[String]): Int32 & Impure = 
    let dbPath      = System/FilePath.new("G:/work/assets/facts/classfile_characteristics2.sqlite");
    let xlsxPath    = System/FilePath.new("G:/work/assets/uxl/scar_new_kids_uxl.xlsx");
    UploadCheck/Main.runMain(dbPath, xlsxPath);
    0


