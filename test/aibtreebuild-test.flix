use FactIO.LinesImporter;
use FactIO.LineEvaluator;

use AssetLib/Aib/BuildTree.{AibRow, readAibRows, writeAibRows};

def runResult(r1: Result[reln, System.Error]): reln & Impure = match r1 {
    case Ok(reln) => reln
    case Err(e) => {
        Console.printLine(System/Error.toString(e));
        #{ }
    }
}


    
@test
def temp01[r](): #{ AibRow | r } & Impure =
    let src = "G:/work/Projects/assets/otl07/otley_stw_ai2_export.csv";
    readAibRows(src) |> runResult      

@test
def main(): Result[Unit, System.Error] & Impure = 
    use Result.flatMap;
    let src = "G:/work/Projects/assets/otl07/otley_stw_ai2_export.csv";
    let dest = "G:/work/Projects/assets/otl07/otley_stw_ai2_export_TREE.csv";
    let* x = readAibRows(src);
    let* _ = writeAibRows(x, dest);
    Ok()  
