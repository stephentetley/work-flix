use AssetLib/AutoLifting/IH06Tree/MatchIH06.{makeIH06MatchesReport};

pub def main(): Result[Unit, System.Error] & Impure =
    use Result.flatMap;    
    let _       = Console.printLine("Running...");
    let aideSrc = System/FilePath.new("G:/work/assets/lifting-equipment-reports/SCARBOROUGH STW.xlsx");
    let ih06Src = System/FilePath.new("G:/work/assets/lifting-equipment-reports/sca19-sms-lft-ih06.txt");
    let output  = System/FilePath.new("G:/work/assets/lifting-equipment-reports/scarbo-ywrefs.xlsx");
    let* _      = makeIH06MatchesReport({aideFile = aideSrc, ih06File = ih06Src, xlsxOutPath = output});
    let _       = Console.printLine("Done");
    Ok()
