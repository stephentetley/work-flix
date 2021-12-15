use SheetIO.NamedRowEvaluator;
use SheetIO/Reader.{XlsxSource};


use AssetLib/Aruba/Base.{S4Floc, S4Equi, S4FlocLevel, S4SubFloc};
use AssetLib/Aruba/S4Hierarchy.{Site, Function, ProcessGroup, Process, System, Subsystem, 
        Equipment, ChildFloc, ChildEqui, S4FlocType, FunctionalLocation, PreorderRow};

use AssetLib/Aruba/Common/Provenance.{Provenance, S4Provenance}; 
use AssetLib/Aruba/Common/Provenance.Provenance.{Bottom, Existing, New, Delete};

use AssetLib/Aruba/S4/Check.{OrphanEquipment, OrphanFuncloc}; 

def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    0

type alias CapSchemeSources = 
    { existingStructureList :: System.FilePath
    , existingIH06Table :: XlsxSource
    , existingIH08Table :: XlsxSource
    , flocWorkList :: XlsxSource
    , equiWorkList :: XlsxSource
    , flocDeleteList :: XlsxSource
    , equiDeleteList :: XlsxSource
    }

def sources(): CapSchemeSources = 
    { existingStructureList = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-ih06-structure-list.txt")
    , existingIH06Table = {path = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-ih08.xlsx"),
                            sheet = "Sheet1"}
    , existingIH08Table = {path = System/FilePath.new("G:/work/assets/capital_schemes/bever/bever-ih06.xlsx"),
                            sheet = "Sheet1"}
    , flocWorkList = {path = System/FilePath.new("G:/work/assets/capital_schemes/bever/beverley-worklist2.xlsx"),
                        sheet = "Floc"}
    , equiWorkList = {path = System/FilePath.new("G:/work/assets/capital_schemes/bever/beverley-worklist2.xlsx"),
                        sheet = "Equi"}
    , flocDeleteList = {path = System/FilePath.new("G:/work/assets/capital_schemes/bever/beverley-worklist2.xlsx"),
                        sheet = "Floc_delete"}
    , equiDeleteList = {path = System/FilePath.new("G:/work/assets/capital_schemes/bever/beverley-worklist2.xlsx"),
                        sheet = "Equi_delete"}
    }

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src         = sources();
    let* base       = AssetLib/Aruba/S4/Import/IH06StructureList.readBaseRelations(src.existingStructureList);
    let* floctypes  = AssetLib/Aruba/S4/Import/IH06Table.readS4FlocTypes(src.existingIH06Table);
    let* equitypes  = AssetLib/Aruba/S4/Import/IH08Table.readS4EquiTypes(src.existingIH08Table);
    let provBase    = AssetLib/Aruba/Common/Provenance.genS4Provenance(Existing, base);
    let* flocDelete = AssetLib/Aruba/S4/Import/DeleteList.readFlocDeleteList(src.flocDeleteList);
    let* equiDelete = AssetLib/Aruba/S4/Import/DeleteList.readEquiDeleteList(src.equiDeleteList);
    let provDelete  = AssetLib/Aruba/Common/Provenance.genS4Provenance(Delete, flocDelete <+> equiDelete);

    println("deleteList...");
    query equiDelete select (x1, x2) from S4Equi(x1, x2) 
        |> Array.foreach(println);  


    println("provDelete...");
    query provDelete select (x1; x2) from S4Provenance(x1; x2) 
        |> Array.foreach(println);  

    let* newFlocs   = AssetLib/Aruba/S4/Import/GenWorkList.readFlocBaseRelations(src.flocWorkList);
    let* newEquis   = AssetLib/Aruba/S4/Import/GenWorkList.readEquiBaseRelations(src.equiWorkList);
    let provNew     = AssetLib/Aruba/Common/Provenance.genS4Provenance(New, newFlocs <+> newEquis);
    let db1         = AssetLib/Aruba/S4/Hierarchy.fromS4BaseRelations(base <+> newFlocs <+> newEquis) 
                            <+> floctypes <+> equitypes <+> provBase <+> provNew <+> provDelete;
    
    /// Temp
    println("Orphan Equi...");
    query db1 <+> AssetLib/Aruba/S4/Check.orphans() select (x1, x2, x3) from OrphanEquipment(x1, x2, x3) |> Array.foreach(println);
    println("Orphan Flocs...");
    query db1 <+> AssetLib/Aruba/S4/Check.orphans() select (x1, x2) from OrphanFuncloc(x1, x2) |> Array.foreach(println);
    /// println("Provenance...");
    /// query db2 select (x1; x2) from S4Provenance(x1; x2) 
    ///     |> Array.foreach(println);

    let puml = AssetLib/Aruba/Common/Provenance.toSaltTreeTable(printKey, printLabel, db1);
    let outpath = System/FilePath.new("E:/coding/work/plantuml/bever_tree1.puml");
    PlantUml/Puml.writePuml(outpath, Text/Charset.utf_8(), puml);
    println("Wrote: ${outpath}");
    println("execPlantUml...");
    let* _ = execPlantUml("svg", outpath);
    Ok()

def printKey(key: String, provenance: Provenance): PlantUml/Creole.Creole = 
    use PlantUml/Creole.{<>, text, oldColor};
    match provenance {
        case New      => oldColor("Green") <> text(key)
        case Delete   => oldColor("Red") <> text(key)
        case Existing => text(key)
        case Bottom   => text(key)
    }

def printLabel(label: String, provenance: Provenance): PlantUml/Creole.Creole = 
    use PlantUml/Creole.{<>, text, oldColor, stroked};
    match provenance {
        case New      => oldColor("Green") <> text(label)
        case Delete   => oldColor("Red") <> stroked(text(label))
        case Existing => text(label)
        case Bottom   => text(label)
    }


def execPlantUml(format: String, srcFile: System.FilePath): Result[Int32, String] & Impure = 
    use Result.flatMap;
    let args = 
        { java = "java.exe"
        , plantUmlJar = System/FilePath.new("C:/ProgramData/Chocolatey/lib/plantuml/tools/plantuml.jar")
        , format = Some(format)
        , sourceFile = srcFile
    };
    PlantUml/Extras.execPlantUml(args)
    