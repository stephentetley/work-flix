use System.Error.{Generic};

use AssetLib/S4/IH06Tree/Datatypes.{IH06File, Header, IH06Row, FlocRow, EquiRow};

@test
def test01(): Result[IH06File, System.Error] & Impure =
    use AssetLib/S4/IH06Tree/Parser.{parseFile};
    let src = "G:/work/Projects/assets/ih06_trees/stab2-ih06.txt";
    parseFile(src)        
    
@test
def main(): Result[Unit, System.Error] & Impure =
    use Result.flatMap;
    use AssetLib/S4/IH06Tree/Parser.{parseFile};
    use AssetLib/S4/IH06Tree/ExportCsv.{exportCsv};
    let src = "G:/work/Projects/assets/ih06_trees/otl07_ih06.txt";    
    let dest = "G:/work/Projects/assets/ih06_trees/otl07_ih06_export.csv";
    let* x = parseFile(src);
    let* _ = exportCsv(x, dest);
    Ok()
