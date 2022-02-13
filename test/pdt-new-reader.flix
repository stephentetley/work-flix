use SheetIO.SheetReader;
use AssetLib/FileIO/PDT/Base.{FieldValue};



pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");

    /// let srcdir  = System/FilePath.new("G:/work/assets/capital_schemes/chell/pdts");
    /// let srcs    = System/Directory.contents(srcdir) |> Result.getWithDefault(Nil) |> List.filter(x -> System/FilePath.getExtension(x) == Some("xlsx"));    
    /// let dst = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-pdt.sqlite");
    
    let srcdir  = System/FilePath.new("G:/work/assets/capital_schemes/sca05/pdts");
    let srcs    = System/Directory.contents(srcdir) |> Result.getWithDefault(Nil) |> List.filter(x -> System/FilePath.getExtension(x) == Some("xlsx"));    
    let dst = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-pdt.sqlite");

    AssetLib/FileIO/PDT/SQLite.createPDTDatabase(srcs, dst) |> println;
    
    0


