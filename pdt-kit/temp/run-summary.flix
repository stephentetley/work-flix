use Applicative.{*>};
use PDTKit/PdtL/Datatypes.{PdtFile};

def main(): Unit \ IO = 
    println("Running...");
    match main1() {
        case Err(msg) => println(msg)
        case Ok()     => ()
    };
    ()

def main1(): Result[Unit, String] \ IO = 
    use Result.flatMap;
    let* dir = Basis/System/FilePath.filePath("G:/work/assets/capital_schemes/hollym-stw/pdts");
    let* _   = PDTKit/BaseReports/Summary.processDirectory(dir);
    Ok()



