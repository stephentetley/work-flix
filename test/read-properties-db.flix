
use AssetLib/Properties/Relations.{StringProperty, IntProperty, FloatProperty};


def main(_: Array[String]): Int32 & Impure = 
    println("Temp1...");
    main01() |> println;
    0
    

def main01(): Result[Int32, String] & Impure = 
    use Result.flatMap;
    let dbpath  = System/FilePath.new("G:/work/assets/capital_schemes/bever/properties.sqlite");
    let* relns  = AssetLib/Properties/ReadProperties.readProperties(dbpath);
    
    query relns select (x1, x2, x3) from StringProperty(x1, x2, x3) |> Array.foreach(println);

    Ok(0)

