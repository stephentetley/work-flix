use System.Error.{Generic};

use AssetLib/S4/FileReaders/ClassList/Datatypes.{ClassList, ClassListFile};
use AssetLib/S4/FileReaders/ClassList/Datatypes.ClassListRow.{ClassRow, CharacteristicRow, ValueRow};
use AssetLib/S4/FileReaders/ClassList/Builder.{buildClassList, allTrees};
use AssetLib/S4/FileReaders/ClassList/Parser.SourceType;
use AssetLib/S4/FileReaders/ClassList/Parser.SourceType.{FlocClasses, EquiClasses};

def printAst(src: ClassListFile): Unit & Impure = 
    let fn = x -> match x { 
        case ClassRow(r1) => Console.printLine("Class:" + r1.name)
        case CharacteristicRow(r1) => Console.printLine("Characteristic:" + r1.name)
        case ValueRow(s) => Console.printLine("Value:" + s)
    };
    List.foreach(fn, src.rows)

def printClasses(src: ClassList): Unit & Impure = 
    List.foreach(x -> Console.printLine(x.name), src.classes)

def renderFile(src: String, srcType: SourceType, cs: Text.Charset, outfile: String): Result[Unit, System.Error] & Impure = 
    use Result.flatMap;
    use AssetLib/S4/FileReaders/ClassList/Parser.{parseFile};
    use AssetLib/Common/ExportHtmlTree.{writeHtmlForest};
    let _ = Console.printLine("renderFile...");
    let* ast = parseFile(src, srcType, cs);
    let _ = printAst(ast);
    let _ = Console.printLine(Int32.toString(List.length(ast.rows)));
    let ans = buildClassList(ast);
    let _ = printClasses(ans);
    let _ = writeHtmlForest(outfile, allTrees(ans));
    Ok()

def main(): Result[Unit, System.Error] & Impure =  
    //renderFile("G:/work/Projects/assets/facts/floc-class-export.txt", FlocClasses, Text/Charset.utf_8(), "e:/coding/work/work-flix/output/floc_classlist.html")
    renderFile("G:/work/Projects/assets/facts/equi-class-export.txt", 
                    EquiClasses, 
                    Text/Charset.iso_8859_1(), 
                    "e:/coding/work/work-flix/output/equi_classlist.html")
