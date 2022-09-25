use Applicative.{*>};
use PDTKit/PdtL/Datatypes.{PdtFile};

def main(): Unit \ IO = 
    println("Running...");
    match main1() {
        case Err(msg) => println(msg)
        case Ok()     => ()
    };
    ()

def main1(): Result[Unit, String] \ IO = 
    use Result.flatMap;
    use AssetS/ChangeReport/Relations.{Change};
    let* path   = Basis/System/Path.newPath("G:/work/assets/change-requests/sample1.xlsx");
    let* rows   = AssetS/ChangeReport/Reader.readChangeReport(path);
    List.foreach(println, List.take(5, rows));
    let relns   = AssetS/ChangeReport/MakeRelations.makeRowRelations(rows) <+> AssetS/ChangeReport/DecodeChanges.decodeChanges();
    query relns select (w, x, y, z) from Change(w, x, y, z) |> List.foreach(println);
    // let relns2 = relns <+> AssetS/ChangeReport/DeriveLats.deriveLats();
    // query relns2 select (w, x, y, z) from FirstRow(w, x, y; z) |> List.foreach(println);
    // query relns2 select (w, x, y, z) from LastRow(w, x, y; z) |> List.foreach(println);
    // query relns2 select (u, v, w, x, y, z) from Change(u, v, w, x, y, z) |> List.foreach(println);
    Ok()



