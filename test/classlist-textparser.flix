use System.Error.{Generic};

use AssetLib/S4/FileReaders/ClassList/Datatypes.{ClassList};


def main(): Result[ClassList, System.Error] & Impure = 
    use AssetLib/S4/FileReaders/ClassList/Parser.{parseFile};
    let src = "G:/work/Projects/assets/facts/floc-class-export.txt";
    parseFile(src)

    
        
