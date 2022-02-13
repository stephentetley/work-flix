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

    AssetLib/FileIO/PDT/SQLite.createPDTDatabase(srcs, dst) |> println;
    /// tempRead() |> println;
    0


