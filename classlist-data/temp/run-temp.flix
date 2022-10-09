

def main(): Unit \ IO = 
    println("Running classlists...");
    match main1() {
        case Err(msg) => println(msg)
        case Ok()     => ()
    };
    ()

def main1(): Result[Unit, String] \ IO = 
    use Result.flatMap;
    let* equipath   = Basis/NIO/File/Path.newPath("G:/work/assets/facts/002-equi-class-list.txt");
    let* flocpath   = Basis/NIO/File/Path.newPath("G:/work/assets/facts/003-floc-class-list.txt");
    let* destpath   = Basis/NIO/File/Path.newPath("G:/work/assets/facts/classlists_facts.sqlite");
    AssetS/ClassList/ClassList.genFlocAndEquiData(flocData = flocpath, equiData = equipath, dest = destpath)

