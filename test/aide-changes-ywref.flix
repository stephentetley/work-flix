use AssetLib/AutoLifting/IH06Tree/MatchIH06.{makeIH06MatchesReport};

pub def main(): Result[Unit, System.Error] & Impure =
    use Result.flatMap;    
    let _       = Console.printLine("Running...");
    let aideSrc = System/FilePath.new("G:/work/assets/lifting-equipment-reports/RIPON STW.xlsx");
    let ih06Src = System/FilePath.new("G:/work/assets/lifting-equipment-reports/ripon-sms-lft-ih06.txt");
    let output  = System/FilePath.new("G:/work/assets/lifting-equipment-reports/ripon-ih06-matches.xlsx");
    let* _      = makeIH06MatchesReport({aideFile = aideSrc, ih06File = ih06Src, xlsxOutPath = output});
    let _       = Console.printLine("Done");
    Ok()
