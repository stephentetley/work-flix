use SheetIO.SheetReader;
use SheetIO.NamedRowEvaluator;
use SheetIO.RowEvaluator;

use AssetLib/S4/FileIO/TransferFile.RowSetter;

def main(_argsv: Array[String]): Int32 & Impure = 
    use SheetIO/SheetReader.{runXlsx};
    Console.printLine("Running...");
    let worklist = System/FilePath.new("G:/work/assets/batch_change/IH08_Orbinox Valves 20201106.xlsx");
    match runXlsx(readWorklist(), worklist) { 
        case Err(e) => Console.printLine("Error: ${e}")
        case Ok(xs) => List.foreach(x ->Console.printLine("${x.equiId}, '${x.newModel}', '${x.newPartNumber}', '${x.newSerialNumber}'") , xs)
    };
    0

type alias SourceRow = 
    { equiId: String
    , newModel: String
    , newPartNumber: String
    , newSerialNumber: String
    }

def readWorklist(): SheetReader[List[SourceRow]] = 
    use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
    let* s1     = getSheetNamed("IH06_20201109");
    let* xs     = namedRowsFrom(s1, 0, 1, evalWorklistRow());
    return(xs)


def evalWorklistRow(): NamedRowEvaluator[SourceRow] = 
    use SheetIO/NamedRowEvaluator.{flatMap, return, getStringNamed, getStringNamedWithDefault};
    use SheetIO/NamedRowEvaluator.{<&>, <*>};
    ((x1, x2, x3, x4) -> 
            { equiId = String.trim(x1)
            , newModel = String.trim(x2)
            , newPartNumber = String.trim(x3)
            , newSerialNumber = String.trim(x4)
            })
        <&> getStringNamed("Equipment")
        <*> getStringNamedWithDefault("Change model to", "")
        <*> getStringNamedWithDefault("Change Part No to", "")
        <*> getStringNamedWithDefault("Change serial to", "")
 
def _setOutputRow(x: SourceRow): RowSetter[Unit] = 
    use AssetLib/S4/FileIO/TransferFile/RowSetter.{flatMap, return, putStringNamed!};
    let* _  = putStringNamed!("EQUI", x.equiId);
    let* _  = putStringNamed!("TYPBZ", x.newModel);
    let* _  = putStringNamed!("MAPA_EEQZ", x.newPartNumber);
    let* _  = putStringNamed!("SERGE", x.newSerialNumber);
    return()