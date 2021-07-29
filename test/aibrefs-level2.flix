
use AibRefCheck/Level2Uploads.{Answer};

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match main1() { 
        case Err(msg) => Console.printLine("Error: ${msg}")
        case Ok() => Console.printLine("Okay.")
    };
    0


def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src = 
        { worklist = {sheet = "PRA SAI Refs", 
                        path = System/FilePath.new("G:/work/assets/aibref-cleanse/level2/S4Lv2FLOCsSAI Refupdate.xlsx")}
        , valuaflocs = System/FilePath.new("G:/work/assets/aibref-cleanse/level2/level2-PRA_valuafloc.txt")
        , outpath    = System/FilePath.new("G:/work/assets/aibref-cleanse/level2/uploads/PRA_upload1.txt")
        };
    let* _          = AibRefCheck/Level2AibOverwriteUploads.genOverwrites(src);
    let _           = Console.printLine("Wrote: ${src.outpath}");

    Ok()