
def srcpaths(): { uxlTemplate: System.FilePath, outpath: System.FilePath } = 
        { uxlTemplate       = System/FilePath.new("G:/work/assets/dwf-overflows/MMOP uXL.xlsx")
        , outpath           = System/FilePath.new("G:/work/assets/dwf-overflows/flix-output_uxl.xlsx")
        }

def main(_args: Array[String]): Int32 & Impure =
    let r1 = DwfOverflow/Rules.getChangeRequestItems("DWF Batch 3");
    let r1b = DwfOverflow/Relations.toChangeRequestDetails(r1);
    List.foreach(x -> Console.printLine("${x.description} | ${x.changeRequestType} | ${x.flFunctionalLocation} | ${x.processRequester}"), r1b);
    let r2 = DwfOverflow/Rules.getFlocData();    
    r2|> unsafeToString |> println;
    
    let r3 = DwfOverflow/Rules.getCharacteristics();
    let r3b = DwfOverflow/Relations.toFlClassifications(r3);
    List.foreach(x -> Console.printLine("${x.functionalLocation} ${x.className} ${x.characteristicName} '${x.charValue}'"), r3b);
    let _ = DwfOverflow/EmitUxl.outputUxl(r1b, r2 , r3, srcpaths().uxlTemplate, srcpaths().outpath) ;

    0 // exit code


