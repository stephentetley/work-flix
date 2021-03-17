

def main(_args: Array[String]): Int32 & Impure =
    let r1 = DwfOverflow/Rules.getChangeRequestItems("DWF Batch 3");
    r1 |> unsafeToString |> println;
    let r2 = DwfOverflow/Rules.getFlocData();
    r2 |> unsafeToString |> println;
    let r3 = DwfOverflow/Rules.getCharacteristics();
    r3 |> unsafeToString |> println;
    0 // exit code


