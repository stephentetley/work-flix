use AssetLib/Aib/FileIO/AideChangeSummary/XlsxReader.{readFile => readAideFile};

use AssetLib/S4/FileIO/IH06Tree/Raw/Datatypes.{IH06Row};
use AssetLib/S4/FileIO/IH06Tree/Raw/Datatypes.IH06Row.{FlocRow, EquiRow};
use AssetLib/S4/FileIO/IH06Tree/Raw/Parser.{parseFileWithBOM => parseIH06File};

pub def main(): Result[Unit, System.Error] & Impure =
    use Result.flatMap;     
    let aideSrc = System/FilePath.new("G:/work/assets/lifting-equipment-reports/SCARBOROUGH STW.xlsx");
    let ih06Src = System/FilePath.new("G:/work/assets/lifting-equipment-reports/sca19-sms-lft-ih06.txt");
    let proc = () -> {
        let* aibList    = readAideFile(aideSrc);
        let* patt       = Text/Regex/Pattern.compile("LIFTING EQUIPMENT/(?<name>.*)/EQUIPMENT: ");
        let _           = List.foreach(x -> Console.printLine("${x.reference} - ${getName(patt, x.assetName)}"), aibList);            
        let* ansIH06    = parseIH06File(ih06Src, Text/Charset.utf_8());
        let _           = List.foreach(showEquiRow, ansIH06.rows);
        Ok()
    };
    proc()

def getName(patt: Text/Regex.Pattern, s: String): String & Impure = 
    Result.getWithDefault(Text/Regex.evalContains(s, patt, Text/Regex/MatchEvaluator.getCaptureNamed("name")), "")

def showEquiRow(row: IH06Row): Unit & Impure = match row { 
    case FlocRow(_) => () as & Impure
    case EquiRow(e1) => Console.printLine("${e1.equiId}, ${e1.description}")
}
