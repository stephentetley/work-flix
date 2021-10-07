use SheetIO.NamedRowEvaluator;
use SheetIO/Reader.{XlsxSource};
use AssetLib/FileIO/S4/ZTable/Relations.{AllowedManufacturer, AllowedManufacturerModel};


pub def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    let src = {sheet = "Sheet1", 
                path = System/FilePath.new("G:/work/assets/capital_schemes/embsay/valve-type.xlsx") };
    match main1(src) { 
        case Ok(_) => Console.printLine("Okay.")
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    0


def main1(src: XlsxSource): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use RelLib/Tuple.{decons4};
    let* rows = SheetIO/Reader.readAllNamedRows(src, evalRow());
    let* db = makeDb(rows);
    println("AibEquiType...");
    query (db <+> rules()) select (x1, x2) from AibEquiType(x1, x2) |> Array.foreach(println);
    println("ValveType...");
    query (db <+> rules()) select (x1, x2) from ValveType(x1, x2) |> Array.foreach(println);
    /// testReg01();
    println("Answers...");
    let ans = query (db <+> rules()) select (x1, x2, x3, x4) from EquiType(x1, x2, x3, x4);
    ans |> Array.foreach(println);
    let patches = RelLib/Organization.intoMap(decons4((x1, _, _, _) -> x1), decons4((_, x2, x3, x4) -> (x2, x3, x4)), ans);
    List.foreach(printWithPatches(patches), rows);
    Ok()


pub def printWithPatches(p: Map[String, (String, String, String)], row: WorkItem): Unit & Impure = 
    match Map.get(row.reference, p) {
        case Some((x1, x2, x3)) => Console.printLine("${row.reference},${row.commonName},${x1},${x2},${x3}")
        case None => Console.printLine("${row.reference},${row.commonName},,,")
    }



type alias WorkItem = 
    { reference  :: String
    , commonName :: String
    , valveType :: String
    }

def makeDb(xs: List[WorkItem]): Result[#{AibEquiType, ValveType | r}, String] & Impure = 
    use Result.flatMap;
    let aibEquiType1 = (itemId, o1) -> match o1 {
        case None => #{}
        case Some(tyname) => #{ AibEquiType(itemId, tyname). }
    };
    let r1  = RelLib/Relation.foldMap(x1 -> if (not String.isEmpty(x1.valveType)) #{ ValveType(x1.reference, x1.valveType). } else #{}, xs);
    let* r2 = RelLib/Relation.foldMapResult(x1 -> Result.map(aibEquiType1(x1.reference), getAibEquiTypeName(x1.commonName)), xs);    
    Ok(r1 <+> r2)

pub def getAibEquiTypeName(commonName: String): Result[Option[String], String] & Impure = 
    use Result.flatMap;
    use Text/Regex/MatchEvaluator.{optional, getCaptureNamed};
    let* patt = Text/Regex/Pattern.compile("(?<equitype>EQUIPMENT: .+)$");
    let eval = getCaptureNamed("equitype");
    match Text/Regex.evalContains(patt, eval, commonName) {
        /// Error means both "not found" and operational error - Regex API needs changing to support optional `evalContains`...
        case Err(_) => Ok(None)
        case Ok(s) => Ok(Some(s))
    }


pub def testReg01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use Text/Regex/MatchEvaluator.{optional, getCaptureNamed};
    let* patt = Text/Regex/Pattern.compile("(?<equitype>EQUIPMENT: .+)$");
    let eval = getCaptureNamed("equitype");
    Text/Regex.evalContains(patt, eval, "FAIL") |> println;
    Text/Regex.evalContains(patt, eval, "SOME TEXT/EQUIPMENT: ISOLATING VALVES") |> println;
    Text/Regex.evalContains(patt, eval, "FAIL2") |> println;
    Ok()



rel EquiType(itemId: String, category: String, objType: String, objClass: String)
rel AibEquiType(itemId: String, typeName: String)
rel ValveType(itemId: String, valveType: String)

def rules(): #{AibEquiType, ValveType, EquiType | r} = #{
    
    EquiType(itemId, "M", "VALV", "VALVBA") :- 
        AibEquiType(itemId, "EQUIPMENT: ISOLATING VALVES"), 
        ValveType(itemId, "Ball").

    EquiType(itemId, "M", "VALV", "VALVGA") :- 
        AibEquiType(itemId, "EQUIPMENT: ISOLATING VALVES"), 
        ValveType(itemId, "Wedge Gate").

    EquiType(itemId, "M", "VALV", "VALVGA") :- 
        AibEquiType(itemId, "EQUIPMENT: ISOLATING VALVES"), 
        ValveType(itemId, "Knife Gate").

    EquiType(itemId, "M", "VALV", "VALVMW") :- 
        AibEquiType(itemId, "EQUIPMENT: MULTI-WAY VALVE").

    EquiType(itemId, "M", "VALV", "VALVNR") :- 
        AibEquiType(itemId, "EQUIPMENT: NON RETURN VALVE").

    EquiType(itemId, "M", "VALV", "VALVRE") :- 
        AibEquiType(itemId, "EQUIPMENT: PRESSURE REGULATING VALVE").

    EquiType(itemId, "M", "VALV", "VALVSF") :- 
        AibEquiType(itemId, "EQUIPMENT: RELIEF/SAFETY VALVE").


    EquiType(itemId, "I", "LSTN", "LSTNFL") :- 
        AibEquiType(itemId, "EQUIPMENT: FLOAT LEVEL INSTRUMENT").

    EquiType(itemId, "I", "LSTN", "LSTNUT") :- 
        AibEquiType(itemId, "EQUIPMENT: ULTRASONIC LEVEL INSTRUMENT").


    EquiType(itemId, "H", "VEPR", "VEPRAW") :- 
        AibEquiType(itemId, "EQUIPMENT: WATER/AIR RECEIVER").

    EquiType(itemId, "H", "VEPR", "VEPRPD") :- 
        AibEquiType(itemId, "EQUIPMENT: PULSATION DAMPER").


    EquiType(itemId, "E", "MCCE", "MCCEPA") :- 
        AibEquiType(itemId, "EQUIPMENT: MCC UNIT").

    EquiType(itemId, "E", "PODE", "PODEUP") :- 
        AibEquiType(itemId, "EQUIPMENT: UPS SYSTEMS").

    EquiType(itemId, "E", "HEAT", "HEATIM") :- 
        AibEquiType(itemId, "EQUIPMENT: IMMERSION HEATER").

    EquiType(itemId, "E", "HEAT", "HEATTR") :- 
        AibEquiType(itemId, "EQUIPMENT: TRACE HEATERS").

    EquiType(itemId, "M", "STRN", "STRNER") :- 
        AibEquiType(itemId, "EQUIPMENT: STRAINER").

}




def evalRow(): NamedRowEvaluator[WorkItem] =
    use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
    use SheetIO/NamedRowEvaluator.{<&>, <*>};
    ((x1, x2, x3) -> 
            { reference = x1
            , commonName = x2
            , valveType = x3
            })
        <&> getTrimmedContentNamed("Reference")
        <*> getTrimmedContentNamed("Common Name")
        <*> getTrimmedContentNamed("Valve Type")