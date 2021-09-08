
use AssetLib/FileIO/S4/UxlFile/Datatypes.{EquipmentData};
use AssetLib/FileIO/S4/ZTable/Datatypes.{ObjTypeManufacturer, ManufacturerModel};

    

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match main1() {
        case Ok() => Console.printLine("Ok")
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    0



def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let ztable1         = System/FilePath.new("G:/work/assets/facts/ztables/ztable-objtype-manuf.txt");
    let* allowedManuf   = AssetLib/FileIO/S4/ZTable/Builtins.loadObjTypeManufacturer(ztable1) |> Result.map(buildObjTypeManuf);
    let ztable2         = System/FilePath.new("G:/work/assets/facts/ztables/ztable-manuf-model.txt");
    let* allowedModel   = AssetLib/FileIO/S4/ZTable/Builtins.loadManufacturerModel(ztable2) |> Result.map(buildManufModel);

    let uxl1            = System/FilePath.new("G:/work/assets/capital_schemes/hudub/output/hudub-oc-equi-uxl-output1.xlsx");
    let* equis          = AssetLib/FileIO/S4/UxlFile/XlsxReader.loadEquipmentData(uxl1);
    let _               = println(uxl1);
    let _               = reportErrors(equis, allowedManuf, allowedModel);
    Ok()

def reportErrors(xs: List[EquipmentData], objMan: Allowed, manMod: Allowed): Unit & Impure = 
    let step = x1 -> match check(x1, objMan, manMod) {
        case Ok() => () as & Impure
        case Err(msg) => Console.printLine("${x1.equiId} ${x1.objectType} ${x1.manufacturer} ==> ${msg}")
    };
    List.foreach(step, xs)

def check(x: EquipmentData, objMan: Allowed, manMod: Allowed): Result[Unit, String] = 
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
