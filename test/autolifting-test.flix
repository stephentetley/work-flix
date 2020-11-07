
use AutoLifting/TypeMapping.TypeAnswer;
use AutoLifting/Datatypes.EquiWorkItem;


def main(): Unit & Impure = 
    match mainResult() {
        case Ok() => Console.printLine("Done.")
        case Err(msg) => Console.printLine("Error: " + System/Error.toString(msg))
    }


def mainResult(): Result[Unit, System.Error] & Impure = 
    use AutoLifting/Common/ReportMonad.{runReportMonad};
    use AutoLifting/ReportMain.{generateChildNewReport};
    let reportConfig = 
        { typeTablePath     = System/FilePath.new("G:/work/assets/lifting-equipment-reports/01.lifting_equipment_types.xlsx")
        , liftingTablePath  = System/FilePath.new("G:/work/assets/lifting-equipment-reports/02.classification_fields.xlsx")
        , siteTablePath     = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx")
        , uxlTemplatePath   = System/FilePath.new("G:/work/assets/lifting-equipment-reports/MMOP_uXL.xlsx")
        };
    let workListPath      = System/FilePath.new("G:/work/assets/lifting-equipment-reports/CALDER VALE STW-with-refs.xlsx");
    let reportProps = 
        { workListPath      = workListPath
        , attribsPaths      = System/FilePath.new("G:/work/assets/lifting-equipment-reports/calde-attribs-export.xlsx") :: Nil
        , memosPaths        = System/FilePath.new("G:/work/assets/lifting-equipment-reports/calde-memos-export.xlsx") :: Nil
        , reportDescription = "Site 01 (GC) 16/10/2020 Stephen"
        , phase2OutPath     = makeOutputName(workListPath, "_new_kids.xlsx")
        , uxlOutPath        = makeOutputName(workListPath, "_new_kids_uxl.xlsx")
        };
    runReportMonad(generateChildNewReport(reportConfig, reportProps))


def makeOutputName(path: System.FilePath, newSuffix: String): System.FilePath = 
    let s = Option.getWithDefault(System/FilePath.getBaseName(path), "");
    let s1 = s + newSuffix;
    System/FilePath.replaceFileName(path, s1)
