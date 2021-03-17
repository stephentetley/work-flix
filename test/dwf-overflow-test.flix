


def main(_args: Array[String]): Int32 & Impure =
    let srcpaths = 
        { uxlTemplate       = System/FilePath.new("G:/work/assets/dwf-overflows/MMOP uXL.xlsx")
        , outpath           = System/FilePath.new("G:/work/assets/dwf-overflows/flix-output_uxl.xlsx")
        , worklist          = System/FilePath.new("G:/work/assets/dwf-overflows/DWF_worklist_for_uxl_gen.xlsx")
        };
    let r1 = DwfOverflow/Rules.getFlocData();    
    r1 |> unsafeToString |> println;
    let r2 = DwfOverflow/Rules.getCharacteristics();
    r2|> unsafeToString |> println;
    let _ = DwfOverflow/EmitUxl.outputNewFlocsUxl("DWF Batch 3", r1, r2, srcpaths.uxlTemplate, srcpaths.outpath);
    main2(srcpaths.worklist);
    0 // exit code

def main2(worklist: System.FilePath): Unit & Impure = 
    match DwfOverflow/Rules/ExcelLoader.readWorkList(worklist) {
        case None => Console.printLine("Bad")
        case Some(db) => db |> unsafeToString |> println
    }



