use AibRefCheck/Level2AibOverwriteUploads.{Sources};

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match main1() { 
        case Err(msg) => Console.printLine("Error: ${msg}")
        case Ok() => Console.printLine("Okay.")
    };
    0

def makeSources(tab: String): Sources = 
    { worklist = {sheet = "${tab} SAI Refs", 
                    path = System/FilePath.new("G:/work/assets/aibref-cleanse/level2/S4Lv2FLOCsSAI Refupdate.xlsx")}
    , downloads = {glob= "${tab}_batch*.txt", 
                    directory = System/FilePath.new("G:/work/assets/aibref-cleanse/level2/downloads_for_valcnt")}
    , outpath    = System/FilePath.new("G:/work/assets/aibref-cleanse/level2/uploads/Level2_${tab}_AIB_REF_upload##.txt")
    }

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src = makeSources("SMS");
    let* _          = AibRefCheck/Level2AibOverwriteUploads.genOverwrites(src);
    let _           = Console.printLine("Wrote: ${src.outpath}");
    Ok()