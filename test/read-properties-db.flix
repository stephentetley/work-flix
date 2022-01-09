use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic, EquiLongText};
use AssetLib/Properties/Relations.{StringProperty, IntProperty, FloatProperty, PropertyAlias};
use AssetLib/Properties/Rules2/CommonRelations.{EquiWorkItem3};
use AssetLib/Properties/Rules2/EquiAttributes.{EquiAttributesSchema, EquiAttributes};
use AssetLib/Properties/AttributesLattice.{Attributes, AttributeValue};

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
                        <+> AssetLib/Properties/Rules2/EquiLongText.equiLongText()
                        <+> AssetLib/Properties/Rules2/EquiAttributes.equiAttributes()
                        <+> dummyWorkList();
    query db2 select (x1, x2, x3, x4, x5) from EquiCharacteristic(x1, x2, x3, x4, x5) |> Array.foreach(println);
    query db2 select (x1, x2, x3) from EquiLongText(x1, x2, x3) |> Array.foreach(println);
    query db2 select (x1; x2) from EquiAttributes(x1; x2) |> Array.foreach(println);

    Ok(0)

def dummyWorkList(): #{EquiWorkItem3, StringProperty | r1} = #{
    EquiWorkItem3("PLI00788787", "TRUT", "TRUTHG").
    EquiWorkItem3("PLI00785314", "EMTR", "EMTRIN").
    EquiWorkItem3("PLI00785304", "GASW", "GASWIP").
    EquiWorkItem3("PLI00785303", "DECO", "DECOEB").
    EquiWorkItem3("PLI00785302", "GASW", "GASWMG").
    EquiWorkItem3("PLI00790119", "FSTN", "FSTNEM").

    // Synthetic properties - not derived from AIB

    StringProperty("PLI00788787", "@S4_NAME", "Gearbox").
    StringProperty("PLI00785314", "@S4_NAME", "Motor").
    StringProperty("PLI00785304", "@S4_NAME", "Switch").
    StringProperty("PLI00785303", "@S4_NAME", "Eyebath").
    StringProperty("PLI00785302", "@S4_NAME", "Switch2").
    StringProperty("PLI00790119", "@S4_NAME", "Flow Meter").


    StringProperty("PLI00788787", "@SOLUTION_ID", "SWE9500").
    StringProperty("PLI00785314", "@SOLUTION_ID", "SWE9500").
    StringProperty("PLI00785304", "@SOLUTION_ID", "SWE9500").
    StringProperty("PLI00785303", "@SOLUTION_ID", "SWE9500").
    StringProperty("PLI00785302", "@SOLUTION_ID", "SWE9500").
    StringProperty("PLI00790119", "@SOLUTION_ID", "SWE9500").

}    