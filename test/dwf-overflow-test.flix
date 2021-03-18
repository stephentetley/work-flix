
use DwfOverflow/Relations.{Floc};



def main(_args: Array[String]): Int32 & Impure =
    let srcpaths = 
        { uxlTemplate       = System/FilePath.new("G:/work/assets/dwf-overflows/MMOP uXL.xlsx")
        , outpath           = System/FilePath.new("G:/work/assets/dwf-overflows/flix-output_uxl_3xDWF.xlsx")
        , worklist          = System/FilePath.new("G:/work/assets/dwf-overflows/DWF_worklist_for_uxl_gen.xlsx")
        , sitemapping       = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx")
        , sitefacts         = System/FilePath.new("G:/work/assets/dwf-overflows/aib-export-stws-with-constr-year.xlsx")
        , sysFlocs          = System/FilePath.new("G:/work/assets/dwf-overflows/file_download-all-WWT-SOF-SET-SYSxx.txt")
        };
    let flocDownloads = 
           System/FilePath.new("G:/work/assets/dwf-overflows/file_download-all-WWT.txt")
        :: System/FilePath.new("G:/work/assets/dwf-overflows/file_download-all-WWT-SOF.txt")
        :: System/FilePath.new("G:/work/assets/dwf-overflows/file_download-all-WWT-SOF-SET.txt")
        :: Nil ;
    Console.printLine("Running...");
    match DwfOverflow/Rules.loadFileData(srcpaths.worklist, srcpaths.sitemapping, srcpaths.sitefacts, srcpaths.sysFlocs, flocDownloads) { 
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
        case Ok(db) => {
            let flocs = DwfOverflow/Rules.get3xDwfFlocs(db);
            Console.printLine("3xFlocs...");
            flocs |> unsafeToString |> println;
            /// rest 
            let r1 = DwfOverflow/Rules.getFlocData(flocs);
            r1 |> unsafeToString |> println;
            let r2 = DwfOverflow/Rules.getCharacteristics(flocs);
            r2|> unsafeToString |> println;
            let _ = DwfOverflow/EmitUxl.outputNewFlocsUxl("DWF Batch 4 3xDWF (GC)", r1, r2, srcpaths.uxlTemplate, srcpaths.outpath);    
            0 // exit code
        }
    }

