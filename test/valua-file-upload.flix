use SheetIO.SheetReader;
use SheetIO.NamedRowEvaluator;

use AssetLib/FileIO/S4/TransferFile.{RowSetter};
use AssetLib/FileIO/S4/TransferFile/Builtins.{ClassEquiRow, ValuaEquiRow};

def solutionId(): String = "B3050170"

def main(_argsv: Array[String]): Int32 & Impure = 
    Console.printLine("Running...");
    let worklist    = System/FilePath.new("G:/work/assets/fire_alarms/worklist.xlsx");
    let classout    = System/FilePath.new("G:/work/assets/fire_alarms/fire_alarms_CLASS_file_upload.txt");
    let valuaout    = System/FilePath.new("G:/work/assets/fire_alarms/fire_alarms_VALUA_file_upload.txt");
    match main1(worklist, classout, valuaout) { 
        case Err(e) => {Console.printLine("Error: ${e}") ; 1}
        case Ok() => {Console.printLine("Wrote: ${classout}"); Console.printLine("Wrote: ${valuaout}"); 0}
    }

def main1(worklist: System.FilePath, classout: System.FilePath, valuaout: System.FilePath): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    use SheetIO/SheetReader.{runXlsx};
    use AssetLib/FileIO/S4/TransferFile/Builtins.{outputClassEquiFile, outputValuaEquiFile};
    let* xs     = runXlsx(readWorklist(), worklist);
    let _       = Console.printLine("${List.length(xs)}");
    let cs      = List.filterMap(makeClassEqui, xs);
    let* _      = outputClassEquiFile("tetleys", cs, classout);
    let vs      = List.map(makeValuaEqui, xs);
    let* _      = outputValuaEquiFile("tetleys", vs, valuaout);
    Ok()  

type alias WorklistRow = 
    { equiId: String
    , site: String
    , description: String
    , floc: String
    , classType: String
    , existingSolutionId: String
    }

def readWorklist(): SheetReader[List[WorklistRow]] = 
    use SheetIO/SheetReader.{flatMap, point, getSheetNamed, namedRowsFrom};      
    let* s1     = getSheetNamed("results2");
    let* xs     = namedRowsFrom(s1, 0, 1, evalWorklistRow());    
    point(xs)


def evalWorklistRow(): SheetIO.NamedRowEvaluator[WorklistRow] = 
    use SheetIO/NamedRowEvaluator.{map, getContentNamed, 
        getStringNamedWithDefault, getInt64Named};
    use SheetIO/NamedRowEvaluator.{<&>, <*>};
    ((x1, x2, x3, x4, x5, x6) -> 
            { equiId                = x1
            , site                  = x2
            , description           = x3
            , floc                  = x4
            , classType             = x5
            , existingSolutionId    = x6
            })
        <&> getContentNamed("equi_id")
        <*> getContentNamed("site")
        <*> getContentNamed("description")
        <*> getContentNamed("floc")
        <*> getContentNamed("classtype")
        <*> getContentNamed("existing_solution_id")

def makeClassEqui(x: WorklistRow): Option[ClassEquiRow] = 
    if (x.existingSolutionId != "")
        None
    else 
        Some({ equi                 = x.equiId
            , className             = "SOLUTION_ID"
            , classType             = "002"
            , internalClassNumber   = "0000000533"
            , status                = Some(1)
            })

def makeValuaEqui(x: WorklistRow): ValuaEquiRow = 
    { equi                          = x.equiId
    , classType                     = "002"
    , charId                        = "SOLUTION_ID"
    , charValue                     = solutionId()
    , code                          = Some(1)
    , valueDescription              = solutionId()
    , intCounterValue               = if (x.existingSolutionId == "") 1 else 2
    , valueFrom                     = "0"
    , valueTo                       = "0"
    }