

def main(_args: Array[String]): Int32 & Impure =
    Console.printLine("Running ${Time/LocalTime.now()}...");
    let src = System/FilePath.new("G:/work/assets/cost-centers/1stPass_Batch3.xlsx");
    let outputDir = System/FilePath.new("G:/work/assets/cost-centers/output-batch3");
    match CostCenters/Main.main1(src, outputDir, 750, "CC_PROD_batch3_upload") {
        case Ok() => {Console.printLine("Done"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }
