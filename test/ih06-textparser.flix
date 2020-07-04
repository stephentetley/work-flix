use System.Error.{Generic};

use AssetLib/S4/FileReaders/IH06Tree/Datatypes.{IH06File, Header, IH06Row, FlocRow, EquiRow};

    
@test
def main(): Result[Unit, System.Error] & Impure =
    use Result.flatMap;
    use AssetLib/S4/FileReaders/IH06Tree/Parser.{parseFile};
    use AssetLib/S4/FileReaders/IH06Tree/ExportCsv.{exportCsv};
    let src = "G:/work/Projects/assets/capital_schemes/ear02/ear02_ih06_export.txt";    
    let dest = "G:/work/Projects/assets/capital_schemes/ear02/ear02_ih06_export.csv";
    let* x = parseFile(src);
    let _ = Console.printLine("parsed");
    let* _ = exportCsv(x, dest);
    Ok()


