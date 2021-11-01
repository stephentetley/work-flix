use AssetLib/Aruba/S4/IH06.{IH06Floc, IH06Equi};
use AssetLib/Aruba/Base.{Floc, Equi, SubFloc, EquiType};

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    main1() |> println;
    0

def main1(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    let src         = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-ih06-all.txt");
    let src2        = {path = System/FilePath.new("G:/work/assets/capital_schemes/wethe-reference/wethe-equi-ih08.xlsx"),
                        sheet = "Sheet1"};
    let* srcRel     = AssetLib/Aruba/S4/IH06Tree.readIH06Relations(src);
    let baseRep     = AssetLib/Aruba/S4/IH06Tree.toBase(srcRel);
    let* extra      = AssetLib/Aruba/S4/IH08Table.readIH08Relations(src2);
    let db          = baseRep <+> extra;
    query db select (x1, x2, x3) from Floc(x1, x2, x3) |> Array.foreach(println);
    query db select (x1, x2) from Equi(x1, x2) |> Array.foreach(println);
    let tyrules = #{
        Type(name) :- EquiType(_, name).
    };
    query db <+> tyrules select x1 from Type(x1) |> Array.foreach(println);
    Ok()
