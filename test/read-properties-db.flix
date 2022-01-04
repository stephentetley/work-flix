use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
use AssetLib/Properties/Relations.{StringProperty, IntProperty, FloatProperty, PropertyAlias};
use AssetLib/Properties/Rules2/CommonRelations.{EquiWorkItem3};

def main(_: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    main01() |> println;
    0
    

def main01(): Result[Int32, String] & Impure = 
    use Result.flatMap;
    let dbpath      = System/FilePath.new("G:/work/assets/capital_schemes/bever/properties.sqlite");
    let* relns      = AssetLib/Properties/ReadProperties.readProperties(dbpath);
    let* metadata   = AssetLib/Properties/ReadProperties.readPropertyAliases(dbpath);
    let db2         = relns <+> metadata
                        <+> AssetLib/Properties/Rules2/EquiCommon.equiCommon() 
                        <+> AssetLib/Properties/Rules2/EquiCharacteristics.equiCharacteristics()
                        <+> dummyWorkList();
    query db2 select (x1, x2, x3, x4, x5) from EquiCharacteristic(x1, x2, x3, x4, x5) |> Array.foreach(println);

    Ok(0)

/// /// This needs to be a metdata table in the DB....
/// def dummyPropertyAlias(): #{PropertyAlias | r1} = #{
///     PropertyAlias("CURRENT IN", "ACTUEM", "ACTU_RATED_CURRENT_A").
///     PropertyAlias("CURRENT IN", "EMTRIN", "EMTR_RATED_CURRENT_A").
///     PropertyAlias("RANGE MIN", "FSTNEM", "FSTN_RANGE_MIN").
///     PropertyAlias("RANGE MAX", "FSTNEM", "FSTN_RANGE_MAX").
///     PropertyAlias("RANGE UNIT", "FSTNEM", "FSTN_RANGE_UNITS").
/// }

def dummyWorkList(): #{EquiWorkItem3, StringProperty | r1} = #{
    EquiWorkItem3("PLI00788787", "TRUT", "TRUTHG").
    EquiWorkItem3("PLI00785314", "EMTR", "EMTRIN").
    EquiWorkItem3("PLI00785304", "GASW", "GASWIP").
    EquiWorkItem3("PLI00785303", "DECO", "DECOEB").
    EquiWorkItem3("PLI00785302", "GASW", "GASWMG").
    EquiWorkItem3("PLI00790119", "FSTN", "FSTNEM").


    StringProperty("PLI00788787", "SOLUTION_ID", "SWE9500").
    StringProperty("PLI00785314", "SOLUTION_ID", "SWE9500").
    StringProperty("PLI00785304", "SOLUTION_ID", "SWE9500").
    StringProperty("PLI00785303", "SOLUTION_ID", "SWE9500").
    StringProperty("PLI00785302", "SOLUTION_ID", "SWE9500").
    StringProperty("PLI00790119", "SOLUTION_ID", "SWE9500").

}    