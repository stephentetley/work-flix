use AssetLib/FileIO/S4/TransferFile/Datatypes.{ClassEquiRow, ValuaEquiRow};
use AssetLib/S4Lite/Datatypes.{UxlSource};
use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, ConditionGrade, LoadingFactor, PerformanceGrade, SurveyYear};
use AssetLib/GenS4.{GenMonad};

def main(_args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    match AssetLib/GenS4/GenMonad.execGenMonad(genAssetCondition(#{})) {
        case Ok(s4lite) => writeUploads(s4lite) |> println
        case Err(msg) => Console.printLine("Error: ${msg}")
    };
    Console.printLine("Done... ${Time/LocalTime.now()}");
    0

def writeUploads(s4Lite: UxlSource): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let output = 
        { classequi = System/FilePath.new("G://work/assets/other/endeavour_wharf/ew_upload_classequi.txt")
        , valuaequi = System/FilePath.new("G://work/assets/other/endeavour_wharf/ew_upload_valuaequi.txt")
        };
    let* _ = AssetLib/S4Lite/EmitUpload.outputClassEquis("tetleys", s4Lite.equiCharacteristics, output.classequi);
    let* _ = AssetLib/S4Lite/EmitUpload.outputValuaEquis("tetleys", s4Lite.equiCharacteristics, output.valuaequi);
    Console.printLine("Success");
    Ok()


def genAssetCondition(_dummy: #{|r1}): GenMonad[Unit] = 
    use AssetLib/GenS4/GenMonad.{flatMap, return, map, liftActionResult, liftAction};
    let src = 
        { aibAgasp = {sheet= "Sheet1", 
            path = System/FilePath.new("G://work/assets/other/endeavour_wharf/end03-agasp-export.xlsx")}
        , s4classequi = System/FilePath.new("G://work/assets/other/endeavour_wharf/end03_classequi.txt")
        , s4valuaequi = System/FilePath.new("G://work/assets/other/endeavour_wharf/end03_valuaequi.txt")
    };
    let* aibAgasp   = AssetLib/GenS4/AibFacts/Attributes/AssetCondition.readAgaspFacts(src.aibAgasp);
    let* s4Class    = liftActionResult(_ -> AssetLib/FileIO/S4/TransferFile/Builtins.readClassEquiFile(src.s4classequi)) |> map(getAssetConditionClass);
    let* s4Equi     = liftActionResult(_ -> AssetLib/FileIO/S4/TransferFile/Builtins.readValuaEquiFile(src.s4valuaequi)) |> map(getAi2AibReference);
    let db          = aibAgasp <+> s4Class <+> s4Equi;
   
    let rules = #{

        /// Need to remake facts with S4 ids...
        ConditionGrade(s4Id, grade, reason) :- 
            Ai2AibReference(s4Id, aibref),
            ConditionGrade(aibref, grade, reason).

        HasAgasp(aibRef) :- ConditionGrade(aibRef, _, _).

        HasAgasp(aibRef) :- LoadingFactor(aibRef, _, _).

        HasAgasp(aibRef) :- PerformanceGrade(aibRef, _, _).

        EquiWorkItem3(s4Id, "XYZ1", "XYZ123") :- 
            Ai2AibReference(s4Id, aibref),
            HasAgasp(aibref), 
            not AssetConditionClass(s4Id).
    };
    let allRelns    = db <+> rules <+> AssetLib/GenS4/Rules/Characteristics/AssetCondition.assetCondition();
    let* _          = liftAction(_ -> query allRelns select (x1, x2, x3) from EquiWorkItem3(x1, x2, x3) |> Array.foreach(println));    
    let* _          = liftAction(_ -> query allRelns select (x1, x2, x3, x4, x5) from EquiCharacteristic(x1, x2, x3, x4, x5) |> Array.foreach(println));
    let* _          = AssetLib/GenS4/GenMonad.tellEquiCharacteristics(allRelns);
    return()

pub rel AssetConditionClass(s4Id: String)

def getAssetConditionClass(xs: List[ClassEquiRow]): #{AssetConditionClass | r} =
    let step = x1 -> match x1.className { 
        case "ASSET_CONDITION" => #{ AssetConditionClass(x1.equi). }
        case _ => #{}
    };
    RelLib/Relation.foldMap(step, xs)

pub rel Ai2AibReference(s4Id: String, aibRefefence: String)

def getAi2AibReference(xs: List[ValuaEquiRow]): #{Ai2AibReference | r} =
    let step = x1 -> match x1.charId { 
        case "AI2_AIB_REFERENCE" => #{ Ai2AibReference(x1.equi, x1.charValue). }
        case _ => #{}
    };
    RelLib/Relation.foldMap(step, xs)




