use SheetIO.SheetReader;
use AssetLib/FileIO/PDT/Base.{FieldValue};


// TODO we want to store 002 equi class list as metadata so we can find equipment object type/class
// from field `Asset Type`

pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
/*
    let srcdir  = System/FilePath.new("G:/work/assets/capital_schemes/chell/pdts");
    let srcs    = System/Directory.contents(srcdir) |> Result.getWithDefault(Nil) |> List.filter(x -> System/FilePath.getExtension(x) == Some("xlsx"));
    let dst = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-pdt.sqlite");
    writeDb(srcs, dst) |> println;

*/    
    storeMetaEqui(System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt")) |> println;
    storeMetaFloc(System/FilePath.new("G:/work/assets/facts/003-floc-class-list.txt")) |> println;
    0


def _writeDb(srcs: List[System.FilePath], dst: System.FilePath): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let* relns  = AssetLib/FileIO/PDT/Reader.readFieldValuesAll(srcs);
    let* _      = BasicDb/DbMonad.runSQLite(AssetLib/FileIO/PDT/SQLite.storeFieldValues("pdt_raw_values", relns), dst);
    Ok()


def storeMetaEqui(src: System.FilePath): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let dst     = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-pdt.sqlite");
    let names   = {classDescriptionTable = "meta_equi_classes", characteristicTable = "meta_equi_characteristics",
                    picklistValueTable = "meta_equi_picklist_values", intRangeTable = "meta_equi_int_ranges"};    
    let* ans    = AssetLib/FileIO/S4/ClassList/Builder.readEquiClassRecords(src);
    let* _      = BasicDb/DbMonad.runSQLite(AssetLib/FileIO/S4/ClassList/SQLite.storeClassListData(names, ans), dst);
    Ok()

def storeMetaFloc(src: System.FilePath): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let dst = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-pdt.sqlite");
    let names   = {classDescriptionTable = "meta_floc_classes", characteristicTable = "meta_floc_characteristics",
                    picklistValueTable = "meta_floc_picklist_values", intRangeTable = "meta_floc_int_ranges"};    
    let* ans    = AssetLib/FileIO/S4/ClassList/Builder.readFlocClassRecords(src);
    let* _      = BasicDb/DbMonad.runSQLite(AssetLib/FileIO/S4/ClassList/SQLite.storeClassListData(names, ans), dst);
    Ok()    