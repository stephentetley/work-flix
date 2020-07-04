use System.Error.{Generic};

use AssetLib/S4/FileReaders/ClassList/Datatypes.{ClassList, ClassListFile};
use AssetLib/S4/FileReaders/ClassList/Datatypes.ClassListRow.{ClassRow};
use AssetLib/S4/FileReaders/ClassList/Builder.{buildClassList, allTrees};

def printAstClasses(src: ClassListFile): Unit & Impure = 
    let fn = x -> match x { 
        case ClassRow(r1) => Console.printLine(r1.name)
        case _ => ()
    };
    List.foreach(fn, src.rows)

def printClasses(src: ClassList): Unit & Impure = 
    List.foreach(x -> Console.printLine(x.name), src.classes)

def main(): Result[Unit, System.Error] & Impure = 
    use Result.flatMap;
    use AssetLib/S4/FileReaders/ClassList/Parser.{parseFile};
    use AssetLib/Common/ExportHtmlTree.{writeHtmlForest};
    let src = "G:/work/Projects/assets/facts/floc-class-export.txt";
    let* ast = parseFile(src);
    let _ = printAstClasses(ast);
    let _ = Console.printLine(Int32.toString(List.length(ast.rows)));
    let ans = buildClassList(ast);
    let _ = printClasses(ans);
    let _ = writeHtmlForest("e:/coding/work/work-flix/output/classlist.html", allTrees(ans));
    Ok()

    
        
