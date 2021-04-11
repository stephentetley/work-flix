



def main(_args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    let sourceFiles = 
        { uxlTemplate = System/FilePath.new("G:/work/assets/valves/MMOP uXL.xlsx")
        , aibHierarchyExport = 
            { file = System/FilePath.new("G:/work/assets/valves/wor07-shd-ai2-valves-export.xlsx")
            , sheet = "Sheet1"
            }
        , aibValveExport = 
            { file = System/FilePath.new("G:/work/assets/valves/wor07-shd-ai2-valves-export.xlsx")
            , sheet = "Sheet1"
            }
        , aibAgaspExport = 
            { file = System/FilePath.new("G:/work/assets/valves/wor07-shd-ai2-agasp-export.xlsx")
            , sheet = "Sheet1"
            }
        , aibMemosExport = 
            { file = System/FilePath.new("G:/work/assets/valves/wor07-shd-ai2-agasp-export.xlsx")
            , sheet = "Sheet1"
            }
        , worklist = 
            { file = System/FilePath.new("G:/work/assets/valves/wor07-worklist.xlsx")
            , sheet = "Sheet1"
            }
        };
    let config = 
        { solutionId = "B7950000"
        , changeRequestName = "New Valves"
        }; 
    let outpath = System/FilePath.new("G:/work/assets/valves/output-uxl1.xlsx");
    match ValveReport/Main.main1(sourceFiles, config, outpath) { 
        case Ok() => 0
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }



