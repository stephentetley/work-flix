use System.Error.{Generic};

use AssetLib/S4/FileReaders/ClassList/Datatypes.{ClassList, ClassListFile};
use AssetLib/S4/FileReaders/ClassList/Datatypes.ClassListRow.{ClassRow, CharacteristicRow, ValueRow};
use AssetLib/S4/FileReaders/ClassList/Builder.{buildClassList, allTrees};
use AssetLib/S4/FileReaders/ClassList/Parser.SourceType;
use AssetLib/S4/FileReaders/ClassList/Parser.SourceType.{FlocClasses, EquiClasses};
use AssetLib/S4/FileReaders/ClassList/ExportCsv.{ExportCsvParams, exportCsv};

// def printAst(src: ClassListFile): Unit & Impure = 
//     let fn = x -> match x { 
//         case ClassRow(r1) => Console.printLine("Class:" + r1.name)
//         case CharacteristicRow(r1) => Console.printLine("Characteristic:" + r1.name)
//         case ValueRow(s) => Console.printLine("Value:" + s)
//     };
//     List.foreach(fn, src.rows)

pub def length(xs: List[a]): Int32 = lengthHelper(xs, 0) 

def lengthHelper(xs: List[a], ac: Int32): Int32 = match xs { 
    case _ :: rs => lengthHelper(rs, ac + 1)
    case Nil => ac
}

// def printClasses(src: ClassList): Unit & Impure = 
//     List.foreach(x -> Console.printLine(x.name), src.classes)

def renderFile(src: String, srcType: SourceType, csvParams: ExportCsvParams, htmlOutfile: String): Result[Unit, System.Error] & Impure = 
    use Result.flatMap;
    use AssetLib/S4/FileReaders/ClassList/Parser.{parseFile};
    use AssetLib/Common/ExportHtmlTree.{writeHtmlForest};
    let _ = Console.printLine("renderFile...");
    let* ast = parseFile(src, srcType, csvParams.charset);
    // let _ = printAst(ast);
    let _ = Console.printLine("Parsing done...");
    let _ = Console.printLine("List length: " + Int32.toString(length(ast.rows)));
    let ans = buildClassList(ast);
    // let _ = printClasses(ans);
    let _ = writeHtmlForest(htmlOutfile, allTrees(ans));

    let _ = exportCsv(ans, csvParams);
    Ok()

def main(): Result[Unit, System.Error] & Impure =  
    //renderFile("G:/work/Projects/assets/facts/floc-class-export.txt", FlocClasses, Text/Charset.utf_8(), "e:/coding/work/work-flix/output/floc_classlist.html")
    renderFile("G:/work/Projects/assets/facts/equi-class-export.txt", 
                    EquiClasses, 
                    { charset = Text/Charset.iso_8859_1()
                    , characteristicsPath = "e:/coding/work/work-flix/output/equi_characteristics.csv"
                    , refinesValuesPath = "e:/coding/work/work-flix/output/equi_refines_values.csv"
                    },
                    "e:/coding/work/work-flix/output/equi_classlist.html"
                    )
