use System.Error.{Generic};


use ShapeShifter/Setup.{SetupParams, outputDb};

def params(): SetupParams = 
    { ih06File          = System/FilePath.new("G:/work/Projects/assets/capital_schemes/eastn/eastn-ih06.txt")
    , flocDownloadFile  = System/FilePath.new("G:/work/Projects/assets/capital_schemes/eastn/eastn_floc_download.txt")
    }

def main(): Result[Unit, System.Error] & Impure = 
    use Result.{flatMap};
    let dest    = System/FilePath.new("G:/work/Projects/assets/capital_schemes/eastn/eastn_ss01.sqlite");
    let* _ = outputDb(params(), dest);
    Ok()



