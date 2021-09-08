use CsoMigration/Loader.{SourceFiles};

def sources(): SourceFiles = 
    { aibCsoExport = System/FilePath.new("G:/work/assets/cso-s4-migration/ai2-cso-export.xlsx")
    , flocMapping = System/FilePath.new("G:/work/assets/cso-s4-migration/AI2toS4Hana_Lvl1_5FlocMapping_ST.xlsx")
    , s4Level1 = System/FilePath.new("G:/work/assets/cso-s4-migration/s4-level1-SITE-flocs.xlsx")
    , s4Level2 = System/FilePath.new("G:/work/assets/cso-s4-migration/s4-level2-WTN-flocs.xlsx")
    , s4Level3 = System/FilePath.new("G:/work/assets/cso-s4-migration/s4-level3-SOF-flocs.xlsx")
    , s4Level4 = System/FilePath.new("G:/work/assets/cso-s4-migration/s4-level4-FLA-and-FLS-flocs.xlsx")
    , s4Level5 = System/FilePath.new("G:/work/assets/cso-s4-migration/s4-level5-SYS-flocs.xlsx")
    }

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1();
    0

def main1(): Result[Int32, String] & Impure = 
    use Result.{flatMap};
    let* facts = CsoMigration/Loader.loadAll(sources());
    let answer = CsoMigration/FlocCalculator.calculate(facts);
    println(answer);
    Ok(0)
