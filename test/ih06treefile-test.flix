use S4Lib/IH06Tree/Datatypes.{IH06File, Header, IH06Row, FlocRow, EquiRow};

@test
def test01(): Result[IH06File, String] & Impure =
    use S4Lib/IH06Tree/Parser.{parseIH06File};
    let src = "G:/work/Projects/assets/ih06_trees/goo04-ih06.txt";
    parseIH06File(src)        
    
@test
def test02(): Result[FlocRow, String] = 
    let str = "  GOO04-WSP                                Waste Water Sludge Processing            GOO04";
    TextParser.runs(S4Lib/IH06Tree/Parser.flocLine(), str)


@test
def test03(): String = 
    let str = "  GOO04-WSP                                Waste Water Sludge Processing            GOO04";
    match TextParser.runs(S4Lib/IH06Tree/Parser.ih06Row(), str) {
        case Err(msg) => msg
        case Ok(_) => "Ok"
    } 