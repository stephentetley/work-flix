use S4Lib/IH06Tree/Datatypes.{IH06File, Header, IH06Row, FlocRow, EquiRow};

@test
def test01(): Result[IH06File, String] & Impure =
    use S4Lib/IH06Tree/Parser.{parseFile};
    let src = "G:/work/Projects/assets/ih06_trees/goo04-ih06.txt";
    parseFile(src)        
    
@test
def test02(): Result[Unit, String] & Impure =
    use Result.flatMap;
    use S4Lib/IH06Tree/Parser.{parseFile};
    use S4Lib/IH06Tree/ExportCsv.{exportCsv};
    let src = "G:/work/Projects/assets/ih06_trees/ewden_ih06.txt";    
    let dest = "G:/work/Projects/assets/ih06_trees/ewden_ih06_export.csv";
    let* x = parseFile(src);
    exportCsv(x, dest)
