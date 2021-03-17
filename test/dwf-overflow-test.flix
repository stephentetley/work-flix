


def main(_args: Array[String]): Int32 & Impure =
    let srcpaths = 
        { uxlTemplate       = System/FilePath.new("G:/work/assets/dwf-overflows/MMOP uXL.xlsx")
        , outpath           = System/FilePath.new("G:/work/assets/dwf-overflows/flix-output_uxl.xlsx")
        };
    let r1 = DwfOverflow/Rules.getFlocData();    
    r1 |> unsafeToString |> println;
    
    let r2 = DwfOverflow/Rules.getCharacteristics();
    r2|> unsafeToString |> println;

    let _ = DwfOverflow/EmitUxl.outputNewFlocsUxl("DWF Batch 3", r1, r2, srcpaths.uxlTemplate, srcpaths.outpath);

    0 // exit code


