
use DwfOverflow/Relations.{Floc};

/// def flocs[r](): #{Floc | r} = #{
///         Floc("SITE1-WWT-SOF-FLS", "Flow Spilling", "SAI00075", "3XDWF OVERFLOW PROC", 4, "SE4652816720", "FLS").
///         Floc("SITE1-WWT-SOF-FLS-SYS01", "6xDWF Overflow System", "SAI00076", "6XDWF OVERFLOW", 5, "SK4451594282", "SCIV").
///     }

def main(_args: Array[String]): Int32 & Impure =
    let srcpaths = 
        { uxlTemplate       = System/FilePath.new("G:/work/assets/dwf-overflows/MMOP uXL.xlsx")
        , outpath           = System/FilePath.new("G:/work/assets/dwf-overflows/flix-output_uxl.xlsx")
        , worklist          = System/FilePath.new("G:/work/assets/dwf-overflows/DWF_worklist_for_uxl_gen.xlsx")
        , sitemapping       = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx")
        , sitefacts         = System/FilePath.new("G:/work/assets/dwf-overflows/aib-export-stws-with-constr-year.xlsx")
        };
    let flocDownloads = 
           System/FilePath.new("G:/work/assets/dwf-overflows/file_download-all-WWT.txt")
        :: System/FilePath.new("G:/work/assets/dwf-overflows/file_download-all-WWT-SOF.txt")
        :: System/FilePath.new("G:/work/assets/dwf-overflows/file_download-all-WWT-SOF-SET.txt")
        :: System/FilePath.new("G:/work/assets/dwf-overflows/file_download-all-WWT-SOF-SET-SYSxx.txt")
        :: Nil ;
    Console.printLine("Running...");
    match DwfOverflow/Rules.loadFileData(srcpaths.worklist, srcpaths.sitemapping, srcpaths.sitefacts, flocDownloads) { 
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
        case Ok(db) => {
            let flocs = DwfOverflow/Rules.getFlocs(db);
            Console.printLine("Flocs...");
            flocs |> unsafeToString |> println;
            /// rest 
            let r1 = DwfOverflow/Rules.getFlocData(flocs);
            r1 |> unsafeToString |> println;
            let r2 = DwfOverflow/Rules.getCharacteristics(flocs);
            r2|> unsafeToString |> println;
            let _ = DwfOverflow/EmitUxl.outputNewFlocsUxl("DWF Batch 3", r1, r2, srcpaths.uxlTemplate, srcpaths.outpath);    
            0 // exit code
        }
    }

