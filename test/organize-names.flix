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

    let names = allCommonNames(rows);

    rows |> List.foreach(printRow(names) >> println);

    Ok()  


def printRow(allNames: Set[String], x1: ExportRow): String = 
    match getParentIfEqui(allNames, x1.commonName) {
        case Some(name) => "${x1.commonName},${name}"
        case None => "${x1.commonName},"
    }

def allCommonNames(xs: List[ExportRow]): Set[String] = 
    List.foldLeft((s, x1) -> Set.insert(x1.commonName, s), Set.empty(), xs)


def getParentIfEqui(s: Set[String], name: String): Option[String] = 
    if (String.contains(name, "EQUIPMENT: "))
        getParent(s, name) |> Option.map(AssetLib/Base/Utils.properCaseName)
    else 
        None

def getParent(s: Set[String], name: String): Option[String] = 
    let strip = start -> Option.flatMap(String.stripPrefix(start));
    let parentFull = getLongestPrefix(s, name);
    let pref = getLongestPrefix(s, parentFull);
    String.stripPrefix(pref, parentFull) 
        |> strip("/")
        

def getLongestPrefix(s: Set[String], name: String): String = 
    let step = (ac, x) -> {
        if (String.startsWith(name, x) and String.length(x) < String.length(name)) {
            if (String.length(x) > String.length(ac)) x else ac
        } else ac
    };
    Set.foldLeft(step, "", s)
