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
    use AssetS/ChangeReport/Relations.{Change, SimpleRow, SourceRow};
    let* inpath     = Basis/System/Path.newPath("G:/work/assets/change-requests/sample1.xlsx");
    let* outpath    = Basis/System/Path.newPath("G:/work/assets/change-requests/sample1.sqlite");
    let* _          = AssetS/ChangeReport/InitDb.createCRDatabase(outpath);
    let* rows       = AssetS/ChangeReport/Reader.readChangeReport(inpath);
    List.foreach(println, List.take(5, rows));
    let db          = AssetS/ChangeReport/MakeRelations.makeRowRelations(rows);
    let sources     = query db select (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13) from SourceRow(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13);
    let* _          = AssetS/ChangeReport/StoreChanges.storeSourceRows(sources, outpath);
    let solns       = (solve db project SimpleRow) <+> AssetS/ChangeReport/DecodeChanges.decodeChanges();
    let changes     = query solns select (w, x, y, z) from Change(w, x, y, z);
    let* _          = AssetS/ChangeReport/StoreChanges.storeChanges(changes, outpath);
    Ok()



