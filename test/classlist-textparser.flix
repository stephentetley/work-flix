use System.Error.{Generic};

use AssetLib/S4/FileReaders/ClassList/Datatypes.{ClassList, ClassListFile};
use AssetLib/S4/FileReaders/ClassList/Datatypes.ClassListRow.{ClassRow};
use AssetLib/S4/FileReaders/ClassList/Builder.{buildClassList};

def printAstClasses(src: ClassListFile): Unit & Impure = 
    let fn = x -> match x { 
        case ClassRow(r1) => Console.printLine(r1.name)
        case _ => ()
    };
    List.foreach(fn, src.rows)

def printClasses(src: ClassList): Unit & Impure = 
    List.foreach(x -> Console.printLine(x.name), src.classes)

def main(): Result[ClassList, System.Error] & Impure = 
    use Result.flatMap;
    use AssetLib/S4/FileReaders/ClassList/Parser.{parseFile};
    let src = "G:/work/Projects/assets/facts/floc-class-export.txt";
    let* ast = parseFile(src);
    let _ = printAstClasses(ast);
    let _ = Console.printLine(Int32.toString(List.length(ast.rows)));
    let ans = buildClassList(ast);
    let _ = printClasses(ans);
    Ok(ans)

    
        
