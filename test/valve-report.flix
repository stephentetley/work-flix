



def main(_args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match main1() { 
        case Ok() => 0
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }


def main1(): Result[Unit, String] & Impure = 
    use Result.{flatMap};
    use ValveReport/Rules.{eqVALV};
    use AssetLib/S4Rel/Relations.{EquiDatum, EquiCharacteristic};
    use ValveReport/Relations.{ValveAttribs};
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
    let* baseRelns = ValveReport/Main.loadRelations(sourceFiles);
    let answers = solve eqVALV() <+> baseRelns;
    (project EquiDatum answers) |> unsafeToString |> println;
    (project EquiCharacteristic answers) |> unsafeToString |> println;
    
    /// (project ValveAttribs answers) |> unsafeToString |> println; 
    /// (project AibEquipment answers) |> unsafeToString |> println; 
    Ok()
