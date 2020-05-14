
use LiftingReport/Relations.{Answer};
use LiftingReport/MakeReport.{makeReport};

def runResult(r1: Result[reln, FactIO.Error]): reln & Impure = match r1 {
    case Ok(reln) => reln
    case Err(e) => {
        Console.printLine(FactIO/Error.toString(e));
        #{ }
    }
}


@test
def test01[r](): #{ Answer | r } & Impure =
    let config = 
        { aiMemoLinesCsv = "G:/work/Projects/assets/lifting-equipment-reports/acomb-ai2-source1-memolines.csv"
        , aiInfosCsv = "G:/work/Projects/assets/lifting-equipment-reports/acomb-ai2-source2-serial-num-etc.csv"
        };
    makeReport(config) |> runResult 
