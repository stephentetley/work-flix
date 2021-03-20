
use AssetLib/S4Rel/Relations.{EquiDatum, EquiCharacteristic};
use FmpSkeleton/Rules.{AibEquipment};

def main(_args: Array[String]): Int32 & Impure =
    Console.printLine("Running...");
    let siteMapSrc = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx");
    let siteMapping = Result.getWithDefault(AssetLib/Facts/SiteMapping.getSiteMapping(siteMapSrc), #{});
    Console.printLine("Site map has been read...");
    let worklist = getWorklist();
    let solns = solve (FmpSkeleton/Rules.distdb() 
                        <+> FmpSkeleton/Rules.status() 
                        <+> FmpSkeleton/Rules.equiAibReference()
                        <+> FmpSkeleton/Rules.equiEastNorth() 
                        <+> siteMapping <+> worklist);
    let r1 = project EquiDatum solns;
    r1 |> unsafeToString |> println;
    let r2 = project EquiCharacteristic solns;
    r2 |> unsafeToString |> println;
    0

def getWorklist[r](): #{AibEquipment | r} = #{

    AibEquipment("PLI00352821", 
        "BROADWAY/(D450) FMP",  "DISTRIBUTION BOARD", "EQUIPMENT: DISTRIBUTION BOARD", 
        Time/LocalDate.new({year = 2001, month = 1, dayOfMonth = 1}),
        "UNKNOWN MANUFACTURER", "UNSPECIFIED", "", "", 
        "SE6503208176", "", "OPERATIONAL").
}

