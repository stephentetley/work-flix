use SheetIO.SheetReader;
use SheetIO.NamedRowEvaluator;

use AssetLib/FileIO/S4/TransferFile.{UploadRowSetter, RowEvaluator => TFRowEvaluator};

def main(_argsv: Array[String]): Int32 & Impure = 
    Console.printLine("Running...");
    let worklist    = System/FilePath.new("G:/work/assets/batch_change/IH08_Orbinox Valves 20201106 editted.xlsx");
    let download    = System/FilePath.new("G:/work/assets/batch_change/orbinox_prod_file_download.txt");
    let outpath     = System/FilePath.new("G:/work/assets/batch_change/orbinox_PROD_file_upload.txt");
    match main1(worklist, download, outpath) { 
        case Err(e) => Console.printLine("Error: ${e}")
        case Ok() => Console.printLine("Wrote: ${outpath}")
    };
    0

def main1(worklist: System.FilePath, download: System.FilePath, outpath: System.FilePath): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    use SheetIO/SheetReader.{runXlsx};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.EntityType.{Equi};
    use AssetLib/FileIO/S4/TransferFile/UploadWriter.{outputUploadFile, execMapUploadRowSetter};
    let headers     = outputHeaders();
    let* xs         = runXlsx(readWorklist(), worklist);
    let* lookups    = readEquiDownloadFile(download);
    let equis       = List.filterMap(x -> makeOutputRow(x, lookups),xs);
    let* tfrows     = execMapUploadRowSetter(headers, setOutputRow!, equis);
    outputUploadFile(Equi, None, "tetleys", headers, tfrows, outpath)

type alias WorklistRow = 
    { equiId: String
    , manufacturer: String
    , changeModel: String
    , changePartNumber: String
    , changeSerialNumber: String
    }

type alias EquipmentRow = 
    { equiId: String
    , functionalLocation: String
    , objectType: String
    , constructionYear: Int32
    , constructionMonth: Int32
    , manufacturer: String
    , model: String
    , partNumber: String
    , serialNumber: String
    }

def makeOutputRow(x: WorklistRow, lookups: Map[String, EquipmentRow]): Option[EquipmentRow] = 
    use Option.{flatMap};
    let* base = Map.get(x.equiId, lookups);
    Some({ equiId               = x.equiId
        , functionalLocation    = base.functionalLocation
        , objectType            = base.objectType
        , constructionYear      = base.constructionYear
        , constructionMonth     = base.constructionMonth
        , manufacturer          = x.manufacturer
        , model                 = if (x.changeModel == "") base.model else x.changeModel
        , partNumber            = if (x.changePartNumber == "") base.partNumber else x.changePartNumber
        , serialNumber          = if (x.changeSerialNumber == "") base.serialNumber else x.changeSerialNumber
        })

def readWorklist(): SheetReader[List[WorklistRow]] = 
    use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
    let* s1     = getSheetNamed("IH06_20201109");
    let* xs     = namedRowsFrom(s1, 0, 1, evalWorklistRow());
    return(xs)


def evalWorklistRow(): SheetIO.NamedRowEvaluator[WorklistRow] = 
    use SheetIO/NamedRowEvaluator.{flatMap, return, getStringNamed, getStringNamedWithDefault};
    use SheetIO/NamedRowEvaluator.{<&>, <*>};
    ((x1, x2, x3, x4, x5) -> 
            { equiId                = String.trim(x1)
            , manufacturer          = String.trim(x2)
            , changeModel           = String.trim(x3)
            , changePartNumber      = String.trim(x4)
            , changeSerialNumber    = String.trim(x5)
            })
        <&> getStringNamed("Equipment")
        <*> getStringNamedWithDefault("Manufacturer", "")
        <*> getStringNamedWithDefault("Change model to", "")
        <*> getStringNamedWithDefault("Change Part No to", "")
        <*> getStringNamedWithDefault("Change serial to", "")

def readEquiDownloadFile(path: System.FilePath): Result[Map[String, EquipmentRow], String] & Impure = 
    use Result.{flatMap};
    use AssetLib/FileIO/S4/TransferFile/Evaluate.{readAllRows};
    let* xs     = readAllRows(evalEquiDownloadRow(), path);
    let ans     = List.foldLeft((ac, x) -> Map.insert(x.equiId, x, ac), Map.empty(), xs);
    Ok(ans)

def evalEquiDownloadRow(): TFRowEvaluator[EquipmentRow] = 
    use AssetLib/FileIO/S4/TransferFile/RowEvaluator.{flatMap, return, getStringNamed, getInt32Named};
    use AssetLib/FileIO/S4/TransferFile/RowEvaluator.{<&>, <*>};
    ((x1, x2, x3, x4, x5, x6, x7, x8, x9) -> 
            { equiId                = x1
            , functionalLocation    = x2
            , objectType            = x3
            , constructionYear      = x4
            , constructionMonth     = x5
            , manufacturer          = x6
            , model                 = x7
            , partNumber            = x8
            , serialNumber          = x9
            })
        <&> getStringNamed("EQUI")                  /// Equipment ID
        <*> getStringNamed("TPLN_EILO")             /// Functional Location
        <*> getStringNamed("EQART_EQU")             /// Object Type
        <*> getInt32Named("BAUJJ")                  /// Construction year
        <*> getInt32Named("BAUMM_EQI")              /// Construction month
        <*> getStringNamed("HERST")                 /// Manufacturer
        <*> getStringNamed("TYPBZ")                 /// Model 
        <*> getStringNamed("MAPA_EEQZ")             /// Manufact Part No
        <*> getStringNamed("SERGE")                 /// Manufact Serial Number


def outputHeaders(): Array[String] & Impure = ["EQUI", "TPLN_EILO", "EQART_EQU", "BAUJJ", "BAUMM_EQI", "HERST", "TYPBZ", "MAPA_EEQZ", "SERGE"]

def setOutputRow!(x: EquipmentRow): UploadRowSetter[Unit] = 
    use AssetLib/FileIO/S4/TransferFile/UploadRowSetter.{flatMap, return, putStringNamed!, 
        putInt32Named!, putPaddedInt32Named!};
    let* _  = putStringNamed!("EQUI", x.equiId);
    let* _  = putStringNamed!("TPLN_EILO", x.functionalLocation);
    let* _  = putStringNamed!("EQART_EQU", x.objectType);
    let* _  = putInt32Named!("BAUJJ", x.constructionYear);
    let* _  = putPaddedInt32Named!("BAUMM_EQI", 2, x.constructionMonth);
    let* _  = putStringNamed!("HERST", x.manufacturer);
    let* _  = putStringNamed!("TYPBZ", x.model);
    let* _  = putStringNamed!("MAPA_EEQZ", x.partNumber);
    let* _  = putStringNamed!("SERGE", x.serialNumber);
    return()