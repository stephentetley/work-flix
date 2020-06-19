use System.Error.{Generic};

use AssetLib/S4/IH06Tree/Datatypes.{IH06File, Header, IH06Row, FlocRow, EquiRow};

// @test
// def main(): Result[String, System.Error] & Impure =
//     use TextParser.{parseFile};
//     use TextParser/Combinators.{seqRight};
//     use AssetLib/S4/IH06Tree/Parser.{header, flocLine};
//     let src = System/FilePath.new("G:/work/Projects/assets/ih06_trees/otl07_ih06.txt");
//     parseFile(seqRight(header(), flocLine()), src, Text/Charset.utf_8())   
//         |> Result.map(x -> x.floc)     
    
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


// @test
// def main(): Result[String, String] =
//     use TextParser.flatMap;
//     use TextParser.{runs, return};
//     use AssetLib/S4/IH06Tree/Parser.{funcLocHeaderLine};
//     let p1 = () -> {
//         let* (s,_) = funcLocHeaderLine();
//         return(s)
//     };
//     runs(p1(), "Functional Location  OTL07                             Valid From      27.05.20")

