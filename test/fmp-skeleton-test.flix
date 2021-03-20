
use AssetLib/S4Rel/Relations.{EquiDatum};
use FmpSkeleton/Rules.{AibEquipment};

def main(_args: Array[String]): Int32 & Impure =
    Console.printLine("Running...");
    let siteMapSrc = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx");
    let siteMapping = Result.getWithDefault(AssetLib/Facts/SiteMapping.getSiteMapping(siteMapSrc), #{});
    let worklist = getWorklist();
    let solns = solve (FmpSkeleton/Rules.distdb() <+> FmpSkeleton/Rules.status() <+> siteMapping <+> worklist);
    let r1 = project EquiDatum solns;
    r1 |> unsafeToString |> println;
    0

def getWorklist[r](): #{AibEquipment | r} = #{

    AibEquipment("PLI00352821", 
        "BROADWAY/(D450) FMP",  "Distribution Board", "EQUIPMENT: DISTRIBUTION BOARD", 
        Time/LocalDate.new({year = 2001, month = 1, dayOfMonth = 1}),
        "UNKNOWN MANUFACTURER", "UNSPECIFIED", "", "", 
        "", "OPERATIONAL").
}

