use SheetIO/Reader.{XlsxSource};

use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic, EquiLongText};
use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, PropertyAlias};
use S4Loader/Base/AttributesLattice.{Attributes, AttributeValue};
use S4Loader/PDT/Rules/Schema.{EquiWorkItem};
use S4Loader/PDT/Rules/EquiAttributes.{EquiAttributesSchema, EquiAttributes};


def main(_: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    main01() |> println;
    0
    

def main01(): Result[Int32, String] & Impure = 
    use Result.flatMap;
    let dbpath      = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-s4loader.sqlite");

    let* db         = BasicDb/DbMonad.runSQLite(S4Loader/PDT/Gen/ReadDb.readDbAll(), dbpath);
    let equiRelns   = dummyWorkList();
    let db2         = db
                        /// <+> S4Loader/PDT/Rules/EquiCommon.equiCommon() 
                        <+> S4Loader/PDT/Rules/EquiCharacteristics.equiCharacteristics()
                        /// <+> S4Loader/PDT/Rules/EquiLongText.equiLongText()
                        <+> S4Loader/PDT/Rules/EquiAttributes.equiAttributes()
                        <+> equiRelns;
    query db2 select (x1, x2, x3, x4) from EquiCharacteristic(x1, x2, x3, x4) |> Array.foreach(println);
    // query db2 select (x1, x2, x3) from EquiLongText(x1, x2, x3) |> Array.foreach(println);
    query db2 select (x1; x2) from EquiAttributes(x1; x2) |> Array.foreach(println);

    Ok(0)


def dummyWorkList(): #{EquiWorkItem | r1} = #{
    EquiWorkItem("F12_C01_RTW Pump 1", "Run To Waste Pump-1").
    EquiWorkItem("F12_C02_RTW Pump 2", "Run To Waste Pump-2").
    EquiWorkItem("F12_C03_RTW Pump 3", "Run To Waste Pump-3").
}    
