
use FactIO/CsvStream.newCsvStreamWithBOM;

type alias ExtractRow = { assetId: String }

def ofCsv(x: FactIO/CsvImport.CsvRow): ExtractRow & Impure =
    use FactIO/CsvImport.getStringByIndex;
    { assetId = Validation.getWithDefault(x.getStringByIndex(0), "_ERROR_")

    }

def toString (x: ExtractRow): String = 
    "{ assetId = " + x.assetId + "}"

@test
def test01(): Result[Unit, String] & Impure =
    use Result.flatMap;
    let path = 
        "G:/work/Projects/assets/flix_asset_patch/equipment-report/Equipment_PLI_extract.csv";
    let* src = newCsvStreamWithBOM(path, System/Charset.utf_8(), true);
    let _ = src |> Stream.map!(ofCsv)
                |> Stream.foreach(x -> Console.printLine(toString(x)));
    Ok()

