use SheetIO.SheetReader;
use SheetIO.NamedRowEvaluator;
use SheetIO.RowEvaluator;

use AssetLib/S4/FileIO/TransferFile.RowSetter;

def main(_argsv: Array[String]): Int32 & Impure = 
    Console.printLine("Running...");
    let worklist = System/FilePath.new("G:/work/assets/batch_change/IH08_Orbinox Valves 20201106.xlsx");
    let outpath = System/FilePath.new("G:/work/assets/batch_change/orbinox_file_upload.txt");
    match main1(worklist, outpath) { 
        case Err(e) => Console.printLine("Error: ${e}")
        case Ok() => Console.printLine("Wrote: ${outpath}")
    };
    0

def main1(srcpath: System.FilePath, outpath: System.FilePath): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    use SheetIO/SheetReader.{runXlsx};
    use AssetLib/S4/FileIO/TransferFile/Datatypes.EntityType.{Equi};
    use AssetLib/S4/FileIO/TransferFile/EmitUploadFile.{outputUploadFile, execMapRowSetter};
    let headers     = outputHeaders();
    let* xs         = runXlsx(readWorklist(), srcpath);
    let* rows        = execMapRowSetter(headers, setOutputRow!, xs);
    outputUploadFile( Equi, "", "tetleys", headers, rows, outpath)

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

def outputHeaders(): Array[String] & Impure = ["EQUI", "TYPBZ", "MAPA_EEQZ", "SERGE"]

def setOutputRow!(x: SourceRow): RowSetter[Unit] = 
    use AssetLib/S4/FileIO/TransferFile/RowSetter.{flatMap, return, putStringNamed!};
    let* _  = putStringNamed!("EQUI", x.equiId);
    let* _  = putStringNamed!("TYPBZ", x.newModel);
    let* _  = putStringNamed!("MAPA_EEQZ", x.newPartNumber);
    let* _  = putStringNamed!("SERGE", x.newSerialNumber);
    return()