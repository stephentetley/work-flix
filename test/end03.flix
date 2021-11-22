use SheetIO/Reader.{XlsxSource};
use SheetIO.NamedRowEvaluator;

use AssetLib/FileIO/S4/TransferFile/Datatypes.{ClassEquiRow, ValuaEquiRow};
use AssetLib/FileIO/S4/ClassList/Relations.{S4ClassMember};

use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, ConditionGrade, LoadingFactor, PerformanceGrade, SurveyYear};
use AssetLib/GenS4.{GenMonad};

def main(_args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    Console.printLine("Done... ${Time/LocalTime.now()}");
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let outpaths = 
        { valuaequi = System/FilePath.new("G://work/assets/other/endeavour_wharf/ew_upload_valuaequi_objchars.txt")
        };
    let* (s4Lite, keymap)   = AssetLib/GenS4/GenMonad.runGenMonad(genCharacteristics());
    let* s4LiteChars        = AssetLib/S4Lite/EmitUpload.renumberSLEquiCharacteristics(keymap, s4Lite.equiCharacteristics);    
    let* _                  = AssetLib/S4Lite/EmitUpload.outputValuaEquis("tetleys", s4LiteChars, outpaths.valuaequi);
    Console.printLine("Success");
    Ok()

def aibExports(): AssetLib/GenS4/GenUxl.OptionalExports  = 
    { aibElectricalExport   = Some({sheet = "Sheet1", 
        path = System/FilePath.new("G://work/assets/other/endeavour_wharf/end03-electrical-export.xlsx")})
    , aibFanExport          = None
    , aibInstrumentExport   = Some({sheet = "Sheet1", 
        path = System/FilePath.new("G://work/assets/other/endeavour_wharf/end03-instrument-export.xlsx")})
    , aibLiftingExport          = None
    , aibPumpExport             = Some({sheet = "Sheet1", 
        path = System/FilePath.new("G://work/assets/other/endeavour_wharf/end03-pump-export.xlsx")})
    , aibTankExport             = None
    , aibValveExport            = Some({sheet = "Sheet1", 
        path = System/FilePath.new("G://work/assets/other/endeavour_wharf/end03-valve-export.xlsx")})        
    , aibVesselExport1          = Some({sheet = "Sheet1", 
        path = System/FilePath.new("G://work/assets/other/endeavour_wharf/end03-vepr1-export.xlsx")})        
    , aibVesselExport2          = Some({sheet = "Sheet1", 
        path = System/FilePath.new("G://work/assets/other/endeavour_wharf/end03-vepr2-export.xlsx")})
    }

def genCharacteristics(): GenMonad[Map[String, String]] = 
    use AssetLib/GenS4/GenMonad.{flatMap, return, map, liftActionResult, liftAction};
    let src = 
        { worklist = {sheet= "Sheet1", 
            path = System/FilePath.new("G://work/assets/other/endeavour_wharf/end03-worklist.xlsx")}
        , s4classequi = System/FilePath.new("G://work/assets/other/endeavour_wharf/end03_classequi_newitems.txt")
        , s4valuaequi = System/FilePath.new("G://work/assets/other/endeavour_wharf/end03_valuaequi_newitems.txt")
        , s4classdict = System/FilePath.new("G://work/assets/facts/002-equi-class-list.txt")
    };
    let* worklist       = liftActionResult(_ -> readWorkItems(src.worklist));
    let* classExport    = liftActionResult(_ -> AssetLib/FileIO/S4/TransferFile/Builtins.readClassEquiFile(src.s4classequi) |> Result.map(getClassRelns));
    let* s4Equi         = liftActionResult(_ -> AssetLib/FileIO/S4/TransferFile/Builtins.readValuaEquiFile(src.s4valuaequi)) |> map(getAi2AibReference);
    let* classDict      = liftActionResult(_ -> AssetLib/FileIO/S4/ClassList/Relations.loadEquiClassRelations(src.s4classdict));
    let db              = worklist <+> classExport <+> classDict <+> s4Equi;
   
    let workItemRules = #{

        EquiWorkItem3(aibref, objtype, className) :-         
            WorkItem(s4ref, objtype, false),
            Ai2AibReference(s4ref, aibref),
            EquiClassItem(s4ref, className),
            S4ClassMember(className, "UNICLASS_CODE").

    };
    let workItems   = db <+> workItemRules;
    let* _          = liftAction(_ -> query workItems select (x1, x2, x3) from EquiWorkItem3(x1, x2, x3) |> Array.foreach(println));
    let* _          = AssetLib/GenS4/GenUxl.tempGenEquiCharacteristics(aibExports(), workItems);
    let* newkeys    = liftAction(_ -> query workItems select (x2, x1) from Ai2AibReference(x1, x2) |> Array.toMap);
    return(newkeys)

pub rel WorkItem(s4ref: String, objtype: String, isChild: Bool)

def readWorkItems(src: XlsxSource): Result[#{WorkItem | r}, String] & Impure = 
    SheetIO/Reader.someNamedRelations(evalWorkItem(), src)

def evalWorkItem(): NamedRowEvaluator[#{WorkItem | r}] =
    use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getLocalDateNamed};
    use SheetIO/NamedRowEvaluator.{<&>, <*>};
    ((x1, x2, x3) -> #{ WorkItem(x1, x2, not String.isEmpty(x3)). })
        <&> getTrimmedContentNamed("Equipment")
        <*> getTrimmedContentNamed("Object Type")
        <*> getTrimmedContentNamed("Superord.Equip.")


pub rel EquiClassItem(equiref: String, className: String)

def getClassRelns(xs: List[ClassEquiRow]): #{EquiClassItem | r} = 
    let step = row -> #{ EquiClassItem(row.equi, row.className). };
    RelLib/Relation.foldMap(step, xs)

pub rel Ai2AibReference(s4Id: String, aibRefefence: String)

def getAi2AibReference(xs: List[ValuaEquiRow]): #{Ai2AibReference | r} =
    let step = x1 -> match (x1.charId, x1.charValue) { 
        case ("AI2_AIB_REFERENCE", code) if String.startsWith(prefix ="PLI", code) => #{ Ai2AibReference(x1.equi, x1.charValue). }
        case _ => #{}
    };
    RelLib/Relation.foldMap(step, xs)