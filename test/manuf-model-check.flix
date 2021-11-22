use SheetIO/Reader.{XlsxSource};
use SheetIO.NamedRowEvaluator;
use AssetLib/FileIO/S4/UxlFile/Datatypes.{EquipmentData};
use AssetLib/FileIO/S4/ZTable/Datatypes.{ObjTypeManufacturer, ManufacturerModel};

    

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match main1() {
        case Ok() => Console.printLine("Ok")
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    0

type alias WorkItem[r: RecordRow] = 
    { equiId :: String
    , objectType :: String 
    , manufacturer :: String
    , modelNumber :: String
    | r
    }

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let ztable1         = System/FilePath.new("G:/work/assets/facts/ztables/ztable-objtype-manuf.txt");
    let* allowedManuf   = AssetLib/FileIO/S4/ZTable/Builtins.loadObjTypeManufacturer(ztable1) |> Result.map(buildObjTypeManuf);
    let ztable2         = System/FilePath.new("G:/work/assets/facts/ztables/ztable-manuf-model.txt");
    let* allowedModel   = AssetLib/FileIO/S4/ZTable/Builtins.loadManufacturerModel(ztable2) |> Result.map(buildManufModel);

    /// let uxl1            = System/FilePath.new("G:/work/assets/capital_schemes/embsay/output/embsay_stw_ferric_uxl.001.xlsx");
    /// let* equis          = readUxlRows(uxl1);

    let worklist        = {path = System/FilePath.new("G:/work/assets/capital_schemes/embsay/embsay-ferric-worklist.xlsx"), 
                            sheet = "Equi"};
    let* equis          = readEquiWorkListRows(worklist);

    let _               = reportErrors(equis, allowedManuf, allowedModel);
    Ok()

pub def readUxlRows(src: System.FilePath): Result[List[WorkItem[r]], String] & Impure = 
    let conv = x1 -> x1 as WorkItem[r];
    Result.map(List.map(conv), AssetLib/FileIO/S4/UxlFile/XlsxReader.loadEquipmentDataMocr(src)) 


pub def readEquiWorkListRows(src: XlsxSource): Result[List[WorkItem[r]], String] & Impure = 
    use SheetIO/NamedRowEvaluator.{optional};
    SheetIO/Reader.rsomeNamedRows(src, evalEquiWorkItem())


def evalEquiWorkItem(): NamedRowEvaluator[Option[WorkItem[r]]] =
    use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
    use  SheetIO/NamedRowEvaluator.{<&>, <*>};
    ((x1, x2, x3, x4) -> 
        if (not String.isEmpty(x2))
            Some({ equiId        = x1
                , objectType    = x2 
                , manufacturer  = x3
                , modelNumber   = x4
                } as WorkItem[r])
        else None) 
    <&> getTrimmedContentNamed("Reference")
    <*> getTrimmedContentNamed("Object Type")
    <*> getTrimmedContentNamed("Manufacturer")
    <*> getTrimmedContentNamed("Model")


def reportErrors(xs: List[WorkItem[r]], objMan: Allowed, manMod: Allowed): Unit & Impure = 
    let step = x1 -> match check(x1, objMan, manMod) {
        case Ok() => () as & Impure
        case Err(msg) => Console.printLine("${x1.equiId} ${x1.objectType} ${x1.manufacturer} ==> ${msg}")
    };
    List.foreach(step, xs)

def check(x: WorkItem[r], objMan: Allowed, manMod: Allowed): Result[Unit, String] = 
    match allowed(x.objectType, x.manufacturer, objMan) {
        case true => match allowed(x.manufacturer, x.modelNumber, manMod) {
            case true => Ok()
            case false => Err("Invalid Model Number - `${x.modelNumber}` for manufacturer `${x.manufacturer}`")
        }
        case false => Err("Invalid Manufactuer - `${x.manufacturer}` for object_type `${x.objectType}`")
    }


type alias Allowed = Map[String, Set[String]]

def buildObjTypeManuf(xs: List[ObjTypeManufacturer]): Allowed = 
    List.foldLeft((ac, x1) -> add(x1.objectType, x1.manufacturer, ac), Map.empty(), xs)

def buildManufModel(xs: List[ManufacturerModel]): Allowed = 
    List.foldLeft((ac, x1) -> add(x1.manufacturer, x1.model, ac), Map.empty(), xs)

def add(k: String, v: String, ac: Allowed): Allowed = match Map.get(k, ac) {
    case Some(_) => Map.adjust(Set.insert(v), k, ac)
    case None => Map.insert(k, Set.singleton(v), ac)
}

def allowed(k: String, v: String, ac: Allowed): Bool = match Map.get(k, ac) {
    case Some(s1) => Set.memberOf(v, s1)
    case None => false
}
