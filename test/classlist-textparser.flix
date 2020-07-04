use System.Error.{Generic};

use AssetLib/S4/FileReaders/ClassList/Datatypes.{ClassList, ClassListFile};
use AssetLib/S4/FileReaders/ClassList/Datatypes.ClassListRow.{ClassRow, CharacteristicRow, ValueRow};
use AssetLib/S4/FileReaders/ClassList/Builder.{buildClassList, allTrees};
use AssetLib/S4/FileReaders/ClassList/Parser.SourceType;
use AssetLib/S4/FileReaders/ClassList/Parser.SourceType.{FlocClasses};

def printAst(src: ClassListFile): Unit & Impure = 
    let fn = x -> match x { 
        case ClassRow(r1) => Console.printLine("Class:" + r1.name)
        case CharacteristicRow(r1) => Console.printLine("Characteristic:" + r1.name)
        case ValueRow(s) => Console.printLine("Value:" + s)
    };
    List.foreach(fn, src.rows)

def printClasses(src: ClassList): Unit & Impure = 
    List.foreach(x -> Console.printLine(x.name), src.classes)

def renderFile(src: String, srcType: SourceType, outfile: String): Result[Unit, System.Error] & Impure = 
    use Result.flatMap;
    use AssetLib/S4/FileReaders/ClassList/Parser.{parseFile};
    use AssetLib/S4/FileReaders/ClassList/Parser.SourceType.{EquiClasses};
    use AssetLib/Common/ExportHtmlTree.{writeHtmlForest};
    let* ast = parseFile(src, srcType);
    let _ = printAst(ast);
    let _ = Console.printLine(Int32.toString(List.length(ast.rows)));
    let ans = buildClassList(ast);
    let _ = printClasses(ans);
    let _ = writeHtmlForest(outfile, allTrees(ans));
    Ok()

def main(): Result[Unit, System.Error] & Impure =  
    renderFile("G:/work/Projects/assets/facts/floc-class-export.txt", FlocClasses, "e:/coding/work/work-flix/output/floc_classlist.html")
        
