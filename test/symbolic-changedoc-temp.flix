use ChangeDoc/Relations.{FunclocChange, FlocLongTextChange, FlocClassChange, FlocCharChange,
        EquipmentChange, EquiLongTextChange, EquiClassChange, EquiCharChange};

/// def config(): ItemReportConfig = 
///     { flocClassList = System/FilePath.new("G:/work/assets/facts/003-floc-class-list.txt")
///     , equiClassList = System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt")
///     , changeAttributesExport = System/FilePath.new("G:/work/assets/change-requests/cr9231-hudub-wwp/hudub-wwp-changeattrs.xlsx")
///     , flocTabExport = Some(System/FilePath.new("G:/work/assets/change-requests/cr9231-hudub-wwp/hudub-wwp-floctab.xlsx"))
///     , equiTabExport = Some(System/FilePath.new("G:/work/assets/change-requests/cr9231-hudub-wwp/hudub-wwp-equitab.xlsx"))
///     , outputPath = System/FilePath.new("G:/work/assets/change-requests/output/hudub-report2.xlsx")
///     }

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    0


def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let changes = System/FilePath.new("G:/work/assets/change-requests/cr9231-hudub-wwp/hudub-wwp-changeattrs.xlsx");
    let* rows = ChangeDoc/Loader.readChangeDoc(changes);
    let updates = ChangeDoc/InterpretChangeAttrs.interpretChanges(rows);
    /// query updates select (x1, x2, x3, x4) from FunclocChange(x1, x2, x3, x4) |> Array.foreach(println);
    /// query updates select (x1, x2, x3, x4, x5) from FlocLongTextChange(x1, x2, x3, x4, x5) |> Array.foreach(println);
    query updates select (x1, x2, x3, x4, x5, x6, x7) from FlocCharChange(x1, x2, x3, x4, x5, x6, x7) |> Array.foreach(println);
    /// query updates select (x1, x2, x3, x4) from EquipmentChange(x1, x2, x3, x4) |> Array.foreach(println);
    /// query updates select (x1, x2, x3, x4, x5) from EquiLongTextChange(x1, x2, x3, x4, x5) |> Array.foreach(println);
    /// query updates select (x1, x2, x3, x4, x5, x6) from EquiClassChange(x1, x2, x3, x4, x5, x6) |> Array.foreach(println);
    query updates select (x1, x2, x3, x4, x5, x6, x7) from EquiCharChange(x1, x2, x3, x4, x5, x6, x7) |> Array.foreach(println);
    Ok()