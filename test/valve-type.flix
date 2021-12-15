use SheetIO.NamedRowEvaluator;
use SheetIO/Reader.{XlsxSource};
use AssetLib/Aruba/Extra/S4EquiType.{S4EquiType, AibEquiType, ValveType};


pub def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    let src = {sheet = "Sheet1", 
                path = System/FilePath.new("G:/work/assets/capital_schemes/embsay/valve-type.xlsx") };
    match main1(src) { 
        case Ok(_) => println("Okay.")
        case Err(msg) => println("Error: ${msg}")
    };
    0



type alias WorkItem = 
    { reference  :: String
    , commonName :: String
    , valveType :: String
    }

def main1(src: XlsxSource): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use RelLib/Tuple.{decons4};
    let* rows   = SheetIO/Reader.allNamedRows(evalRow(), src);
    let* rowdb  = makeDb(rows);
    let db      = rowdb <+> AssetLib/Aruba/Extra/S4EquiType.s4EquiTypeRules();
    println("AibEquiType...");
    query db select (x1, x2) from AibEquiType(x1, x2) |> Array.foreach(println);
    println("ValveType...");
    query db select (x1, x2) from ValveType(x1, x2) |> Array.foreach(println);
    let ans     = query db select (x1, x2, x3, x4) from S4EquiType(x1, x2, x3, x4);
    println("Csv...");
    let patches = RelLib/Organization.intoMap(decons4((x1, _, _, _) -> x1), decons4((_, x2, x3, x4) -> (x2, x3, x4)), ans);
    List.foreach(printWithPatches(patches), rows);
    Ok()


pub def printWithPatches(p: Map[String, (String, String, String)], row: WorkItem): Unit & Impure = 
    match Map.get(row.reference, p) {
        case Some((x1, x2, x3)) => println("${row.reference},${row.commonName},${x1},${x2},${x3}")
        case None => println("${row.reference},${row.commonName},,,")
    }



def makeDb(xs: List[WorkItem]): Result[#{AibEquiType, ValveType | r}, String] = 
    use Result.flatMap;
    use AssetLib/Aruba/Extra/S4EquiType.{getTypeFromCommonName};
    let aibEquiType1 = (itemId, o1) -> match o1 {
        case None => #{}
        case Some(tyname) => #{ AibEquiType(itemId, tyname). }
    };
    let r1  = RelLib/Relation.foldMap(x1 -> if (not String.isEmpty(x1.valveType)) #{ ValveType(x1.reference, x1.valveType). } else #{}, xs);
    let* r2 = RelLib/Relation.foldMapResult(x1 -> Result.map(aibEquiType1(x1.reference), getTypeFromCommonName(x1.commonName)), xs);    
    Ok(r1 <+> r2)


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


/// rel EquiType(itemId: String, category: String, objType: String, objClass: String)
/// rel AibEquiType(itemId: String, typeName: String)
/// rel ValveType(itemId: String, valveType: String)

/// def rules(): #{AibEquiType, ValveType, EquiType | r} = #{
    
///     EquiType(itemId, "M", "VALV", "VALVBA") :- 
///         AibEquiType(itemId, "EQUIPMENT: ISOLATING VALVES"), 
///         ValveType(itemId, "Ball").

///     EquiType(itemId, "M", "VALV", "VALVGA") :- 
///         AibEquiType(itemId, "EQUIPMENT: ISOLATING VALVES"), 
///         ValveType(itemId, "Wedge Gate").

///     EquiType(itemId, "M", "VALV", "VALVGA") :- 
///         AibEquiType(itemId, "EQUIPMENT: ISOLATING VALVES"), 
///         ValveType(itemId, "Knife Gate").

///     EquiType(itemId, "M", "VALV", "VALVMW") :- 
///         AibEquiType(itemId, "EQUIPMENT: MULTI-WAY VALVE").

///     EquiType(itemId, "M", "VALV", "VALVNR") :- 
///         AibEquiType(itemId, "EQUIPMENT: NON RETURN VALVE").

///     EquiType(itemId, "M", "VALV", "VALVRE") :- 
///         AibEquiType(itemId, "EQUIPMENT: PRESSURE REGULATING VALVE").

///     EquiType(itemId, "M", "VALV", "VALVSF") :- 
///         AibEquiType(itemId, "EQUIPMENT: RELIEF/SAFETY VALVE").


///     EquiType(itemId, "I", "LSTN", "LSTNFL") :- 
///         AibEquiType(itemId, "EQUIPMENT: FLOAT LEVEL INSTRUMENT").

///     EquiType(itemId, "I", "LSTN", "LSTNUT") :- 
///         AibEquiType(itemId, "EQUIPMENT: ULTRASONIC LEVEL INSTRUMENT").


///     EquiType(itemId, "H", "VEPR", "VEPRAW") :- 
///         AibEquiType(itemId, "EQUIPMENT: WATER/AIR RECEIVER").

///     EquiType(itemId, "H", "VEPR", "VEPRPD") :- 
///         AibEquiType(itemId, "EQUIPMENT: PULSATION DAMPER").


///     EquiType(itemId, "E", "MCCE", "MCCEPA") :- 
///         AibEquiType(itemId, "EQUIPMENT: MCC UNIT").

///     EquiType(itemId, "E", "PODE", "PODEUP") :- 
///         AibEquiType(itemId, "EQUIPMENT: UPS SYSTEMS").

///     EquiType(itemId, "E", "HEAT", "HEATIM") :- 
///         AibEquiType(itemId, "EQUIPMENT: IMMERSION HEATER").

///     EquiType(itemId, "E", "HEAT", "HEATTR") :- 
///         AibEquiType(itemId, "EQUIPMENT: TRACE HEATERS").

///     EquiType(itemId, "M", "STRN", "STRNER") :- 
///         AibEquiType(itemId, "EQUIPMENT: STRAINER").

/// }


