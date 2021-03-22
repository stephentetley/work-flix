use AssetLib/AibRel/HierarchicalRelations.{AibSite, AibFloc, AibEquipment};
use AssetLib/S4Rel/Relations.{FlocDatum, FlocCharacteristic, EquiDatum, EquiCharacteristic};
use FmpSkeleton/Main.{main1};

def main(_args: Array[String]): Int32 & Impure =
    Console.printLine("Running...");
    let config = 
        { siteMappingFile   = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx")
        , sourceDir         = System/FilePath.new("G:/work/assets/fmp-new-sites/sites")
        }; 
    match main1(config) {
        case Ok() => {Console.printLine("Okay."); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }

///     let siteMapSrc = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx");
///     let siteMapping = Result.getWithDefault(AssetLib/Facts/SiteMapping.getSiteMapping(siteMapSrc), #{});
///     Console.printLine("Site map has been read...");
///     let worklist = getWorklist();
///     let solns = solve (FmpSkeleton/Rules.distdb() 
///                         <+> FmpSkeleton/Rules.netwtl() 
///                         <+> FmpSkeleton/Rules.kiskki() 
///                         <+> FmpSkeleton/Rules.status() 
///                         <+> FmpSkeleton/Rules.equiAibReference()
///                         <+> FmpSkeleton/Rules.equiEastNorth() 
///                         <+> siteMapping <+> worklist);
///     let r1 = project EquiDatum solns;
///     r1 |> unsafeToString |> println;
///     let r2 = project EquiCharacteristic solns;
///     r2 |> unsafeToString |> println;
///     let r3 = project FlocDatum solns;
///     r3 |> unsafeToString |> println;
///     temp01();
///     0

/// def processSite(src: FilePath)


/// def getWorklist[r](): #{AibEquipment | r} = #{

///     AibEquipment("PLI00352821", 
///         "BROADWAY/(D450) FMP",  "DISTRIBUTION BOARD", "EQUIPMENT: DISTRIBUTION BOARD", 
///         Time/LocalDate.new({year = 2001, month = 1, dayOfMonth = 1}),
///         "UNKNOWN MANUFACTURER", "UNSPECIFIED", "", "", 
///         "SE6503208176", "", "OPERATIONAL", "todo").

///     AibEquipment("PLI00890075", 
///         "BROADWAY/(D450) FMP",  "LUCI PILLAR", "EQUIPMENT: KIOSK", 
///         Time/LocalDate.new({year = 1970, month = 1, dayOfMonth = 1}),
///         "UNKNOWN MANUFACTURER", "UNSPECIFIED", "", "", 
///         "SE6503208176", "", "OPERATIONAL", "todo").

///     AibEquipment("PLI00359982", 
///         "BROADWAY/(D450) FMP",  "TELEMETRY OUTSTATION", "EQUIPMENT: TELEMETRY OUTSTATION", 
///         Time/LocalDate.new({year = 2001, month = 1, dayOfMonth = 1}),
///         "METASPHERE", "POINT BLUE", "", "11134501", 
///         "SE6503208176", "", "OPERATIONAL", "todo").

/// }


/// /// def getEquipmentType(equiCommonName: String): String = 
/// ///     String.breakOnLeft("EQUIPMENT: ", equiCommonName) |> snd

/// /// def getEquipmentName(parent: String, equiCommonName: String): String = 
/// ///     let s1 = String.breakOnRight("/EQUIPMENT: ", equiCommonName) |> fst
/// ///     breakOnLeft

/// def temp01(): Unit & Impure = 
///     let path = System/FilePath.new("G:/work/assets/fmp-new-sites/sites/aib-export-deepcar-man-rd.xlsx");
///     let facts1 = AssetLib/AibRel/HierarchicalRelations.readAibSiteFacts(path);
///     let facts = solve Result.getWithDefault(facts1, #{});
///     let r1 = project AibSite facts;  
///     r1 |> unsafeToString |> println;
///     let r2 = project AibFloc facts;
///     r2 |> unsafeToString |> println;
///     let r3 = project AibEquipment facts;
///     r3 |> unsafeToString |> println;
///     ()