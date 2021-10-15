use AssetQuery/Aib/Loader.{ExportRow};
   
def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use RelLib/RegexExtractor.{extract};
    let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/embsay/embsay-site-export.xlsx"), 
                sheet="Sheet1"};
    let* rows  = AssetQuery/Aib/Loader.loadExportRows(src);

    let parents = AssetLib/AssetQuery/Extra/AibHierarchyNames.getParentNamesMap(rows);

    rows |> List.foreach(printRow(parents) >> println);

    Ok()  


def printRow(parents: Map[String, String], x1: ExportRow): String = 
    match Map.get(x1.reference, parents) {
        case Some(name) => 
            if (String.contains(substr = "EQUIPMENT: ", x1.commonName))
                "${x1.commonName},${AssetLib/Base/Utils.properCaseName(name)}"
            else "${x1.commonName},"
        case None => "${x1.commonName},"
    }


