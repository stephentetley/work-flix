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
    use AssetS/ChangeReport/Relations.{Change, SourceRow};
    let* inpath     = Basis/System/Path.newPath("G:/work/assets/change-requests/sample1.xlsx");
    let* outpath    = Basis/System/Path.newPath("G:/work/assets/change-requests/sample1.sqlite");
    let* _          = AssetS/ChangeReport/InitDb.createCRDatabase(outpath);
    let* rows       = AssetS/ChangeReport/Reader.readChangeReport(inpath);
    List.foreach(println, List.take(5, rows));
    let relns       = AssetS/ChangeReport/MakeRelations.makeRowRelations(rows) <+> AssetS/ChangeReport/DecodeChanges.decodeChanges();
    let sources     = query relns select (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13) from SourceRow(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13);
    let* _          = AssetS/ChangeReport/StoreChanges.storeSourceRows(sources, outpath);
    let changes     = query relns select (w, x, y, z) from Change(w, x, y, z);
    let* _          = AssetS/ChangeReport/StoreChanges.storeChanges(changes, outpath);

    // let relns2 = relns <+> AssetS/ChangeReport/DeriveLats.deriveLats();
    // query relns2 select (w, x, y, z) from FirstRow(w, x, y; z) |> List.foreach(println);
    // query relns2 select (w, x, y, z) from LastRow(w, x, y; z) |> List.foreach(println);
    // query relns2 select (u, v, w, x, y, z) from Change(u, v, w, x, y, z) |> List.foreach(println);
    Ok()



