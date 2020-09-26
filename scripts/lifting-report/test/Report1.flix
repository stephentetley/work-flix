
use LiftingReport/Relations.{Answer};
use LiftingReport/MakeReport.{makeReport};

// def runResult(r1: Result[reln, System.Error]): reln & Impure = match r1 {
//     case Ok(reln) => reln
//     case Err(e) => {
//         Console.printLine(FactIO/Error.toString(e));
//         #{ }
//     }
// }


@test
def test01(): Result[Unit, System.Error] & Impure =
    let config = 
        { aiMemoLinesCsv    = "G:/work/assets/lifting-equipment-reports/ewden-ai2-source-memolines.csv"
        , aiInfosCsv        = "G:/work/assets/lifting-equipment-reports/ewden-ai2-source-serial-num-etc.csv"
        , equiMatchesCsv    = "G:/work/assets/lifting-equipment-reports/01.lifting_equipment_types.csv"
        , outputCsv         = "G:/work/assets/lifting-equipment-reports/ewden_report1_output.csv"
        };
    makeReport(config)
