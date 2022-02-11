use SheetIO.SheetReader;
use AssetLib/FileIO/PDT/Base.{FieldValue};


// TODO we want to store 002 equi class list as metadata so we can find equipment object type/class
// from field `Asset Type`

pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");

    /// let srcdir  = System/FilePath.new("G:/work/assets/capital_schemes/chell/pdts");
    /// let srcs    = System/Directory.contents(srcdir) |> Result.getWithDefault(Nil) |> List.filter(x -> System/FilePath.getExtension(x) == Some("xlsx"));    
    /// let dst = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-pdt.sqlite");
    
    let srcdir  = System/FilePath.new("G:/work/assets/capital_schemes/sca05/pdts");
    let srcs    = System/Directory.contents(srcdir) |> Result.getWithDefault(Nil) |> List.filter(x -> System/FilePath.getExtension(x) == Some("xlsx"));    
    let dst = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-pdt.sqlite");

    writeDb(srcs, dst) |> println;
    /// tempRead() |> println;
    0


def writeDb(srcs: List[System.FilePath], dst: System.FilePath): Result[Int32, String] & Impure = 
    use Applicative.{*>};

    let actions = AssetLib/FileIO/PDT/SQLite.createPDTTables() *>
                    AssetLib/FileIO/PDT/SQLite.storeFieldValuesAll(srcs);
    BasicDb/DbMonad.runSQLite(actions, dst)
