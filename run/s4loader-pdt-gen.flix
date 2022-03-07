use SheetIO/Reader.{XlsxSource};

use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic, EquiLongText};

use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, PropertyAlias, EquiObjectClass};
use S4Loader/Base/AttributesLattice.{Attributes, AttributeValue};
use S4Loader/Floc/WorkList.{FlocWorkItem};
use S4Loader/PDT/Rules/Schema.{EquiWorkItem};
use S4Loader/PDT/Rules/EquiAttributes.{EquiAttributesSchema, EquiAttributes};


def main(_: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    main01() |> println;
    0
    

def outputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/1909_AIW_MOCR_Template.xlsx")
    , changeRequestName = "Chello ## UXL"
    , outpath = System/FilePath.new("G:/work/assets/capital_schemes/chell/output/chell_pdt_uxl.xlsx")
    }

def main01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let dbpath          = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-s4loader.sqlite");
    let flocsrc         = {path = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-pdt-worklist.xlsx"),
                            sheet = "Floc"};
    let equisrc         = {path = System/FilePath.new("G:/work/assets/capital_schemes/chell/chell-pdt-worklist.xlsx"), 
                            sheet = "Equi"};
    let* _              = S4Loader/Uxl/GenUxl.generatePDTUxl(outputArgs(), {dbpath = dbpath, flocsrc = flocsrc, equisrc = equisrc});
    Ok()
