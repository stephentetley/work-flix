use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
use AssetLib/Properties/Relations.{StringProperty, IntProperty, FloatProperty};
use AssetLib/Properties/Rules2/CommonRelations.{EquiWorkItem3};

def main(_: Array[String]): Int32 & Impure = 
    println("Temp1...");
    main01() |> println;
    0
    

def main01(): Result[Int32, String] & Impure = 
    use Result.flatMap;
    let dbpath  = System/FilePath.new("G:/work/assets/capital_schemes/bever/properties.sqlite");
    let* relns  = AssetLib/Properties/ReadProperties.readProperties(dbpath);
    
    query relns select (x1, x2, x3) from StringProperty(x1, x2, x3) |> Array.foreach(println);

    let db2 = relns <+> AssetLib/Properties/Rules2/EquiCommon.equiCommon() <+> dummyWorkList();
    query db2 select (x1, x2, x3, x4, x5) from EquiCharacteristic(x1, x2, x3, x4, x5) |> Array.foreach(println);

    Ok(0)

def dummyWorkList(): #{EquiWorkItem3, StringProperty | r1} = #{
    EquiWorkItem3("PLI00160144", "PUMS", "PUMSMO").
    StringProperty("PLI00160144", "SOLUTION_ID", "SWE9500").
}    