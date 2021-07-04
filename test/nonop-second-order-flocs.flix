use SheetIO.NamedRowEvaluator;
use SheetIO.RowEvaluator;
use SheetIO.SheetReader;
use AssetScripts/NonOp/Relations.{SecondOrderFlocWorkItem};

    

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running...");
    main1();
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    let aibReport = System/FilePath.new("G:/work/assets/non-op-bins/AI2NonOp_S4ImportBatches.xlsx");
    let sites = System/FilePath.new("G:/work/assets/non-op-bins/sitelist-ih06.xlsx");
    let* sitemap = AssetScripts/NonOp/Loader.readSiteFlocs("Sheet1", sites);
    let worklist = #{ 
        SecondOrderFlocWorkItem("SAI00001407"). 
        SecondOrderFlocWorkItem("SAI00001407").
        SecondOrderFlocWorkItem("SAI00251744"). 
    };
    let ans = AssetScripts/NonOp/SecondOrderFlocs.genFlocs(sitemap <+> worklist);
    query ans select (x1, x2, x3, x4, x5, x6, x7) from FunctionalLocation(x1, x2, x3, x4, x5, x6, x7)
        |> Array.foreach(println);

    query ans select (x1, x2, x3, x4, x5) from FlocCharacteristic(x1, x2, x3, x4, x5)
        |> Array.foreach(println);


    let* equiTypes = AssetScripts/NonOp/Loader.readPlantAssetTypes("NonOpStatus_S4Presence", aibReport);
    query equiTypes select (x1, x2) from PlantAssetType(x1, x2)
        |> Array.foreach(println);

    Ok()