use SheetIO.SheetReader;
use AssetLib/FileIO/PDT/Base.{FieldValue};


// TODO we want to store 002 equi class list as metadata so we can find equipment object type/class
// from field `Asset Type`

pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");

    let srcdir  = System/FilePath.new("G:/work/assets/capital_schemes/chell/pdts");
    let srcs    = System/Directory.contents(srcdir) |> Result.getWithDefault(Nil) |> List.filter(x -> System/FilePath.getExtension(x) == Some("xlsx"));    
    let dst = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-pdt.sqlite");
    writeDb(srcs, dst) |> println;
    /// tempRead() |> println;
    0


def writeDb(srcs: List[System.FilePath], dst: System.FilePath): Result[Int32, String] & Impure = 
    use Applicative.{*>};
    let tableNames = 
        { valuesTable = "pdt_raw_values"
        , fileIndicesTable = "pdt_file_indices"
        , valuesWithShortNameView = "pdt_values_with_item_name"
        };
    let actions = AssetLib/FileIO/PDT/SQLite.createPDTTables(tableNames) *>
                    AssetLib/FileIO/PDT/SQLite.storeFieldValuesAll(tableNames, srcs);
    BasicDb/DbMonad.runSQLite(actions, dst)

/*
def tempRead(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src1 = System/FilePath.new("G:/work/assets/capital_schemes/chell/pdts/CHELL WBK TWP MLP DS H 0001 CR.001 - EQUI_ACTUATOR_2 - RTW System.xlsx");
    let* xs1 = SheetIO/SheetReader.runXlsx(AssetLib/FileIO/PDT/Reader.readDataSheet(), src1);
    println("${src1} - lines read: ${List.length(xs1)}");
    let src2 = System/FilePath.new("G:/work/assets/capital_schemes/chell/pdts/CHELL WBK TWP MLP DS H 0001 CR.001 - EQUI_ACTUATOR_3 - East Reservoir.xlsx");
    let* xs2 = SheetIO/SheetReader.runXlsx(AssetLib/FileIO/PDT/Reader.readDataSheet(), src1);
    println("${src2} - lines read: ${List.length(xs2)}");
    List.foreach(x1 -> println("${x1.rowName} --- ${x1.cellValues}"), xs2);
    Ok()
*/