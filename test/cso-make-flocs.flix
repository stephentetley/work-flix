use SheetIO/Reader.{XlsxSource};
use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};

/// Need to be annotated with an index...
pub def uxlOutputArgs(): UxlOutputArgs = 
    { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/MMOP uXL.xlsx")
    , changeRequestName = "ACH Flocs for Added Sites Batch ##"
    , outpath = System/FilePath.new("G:/work/assets/cso-s4-migration/output/cso-migration-flocs##-uxl.xlsx")
    }


def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    let src = {path = System/FilePath.new("G:/work/assets/cso-s4-migration/gen-flocs-worklist.xlsx"), 
                sheet = "Worklist"};
    match CsoMigration/MakeFlocs.genFlocUxl(src, uxlOutputArgs()) {
        case Ok() => {Console.printLine("Ok"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }

