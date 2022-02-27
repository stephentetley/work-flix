use PDTKit/Lint/Base/Schema.{Warning, PdtValueRow, MetaPdtAssetType};

pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    main01() |> println;
    0

def main01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let srcs    = 
        { pdtDB = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-pdt.sqlite")
        , assetTypesCsv = System/FilePath.new("E:/coding/work/work-flix/data/S4Loader_configs/pdt_asset_types.csv")
        , ztableManuModel = System/FilePath.new("G:/work/assets/facts/ztables/ztable-manuf-model.txt")
        , ztableObjTypeManuf = System/FilePath.new("G:/work/assets/facts/ztables/ztable-objtype-manuf.txt")
        };
    let _dst     = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-pdt-lint.xlsx");
    let* relns  = PDTKit/Lint/Base/Loader.readAll(srcs);
    let ans     = 
        relns <+> PDTKit/Lint/Rules/ManufacturerModel.invalidManufacturerModel()
              <+> PDTKit/Lint/Rules/AssetName.invalidAssetName();
    query ans select (x1, x2, x3, x4) from Warning(x1, x2, x3, x4) |> Array.foreach(println);
    /// query ans select (x1, x2, x3, x4) from MetaPdtAssetType(x1, x2, x3, x4) |> Array.foreach(println);
    Ok()
