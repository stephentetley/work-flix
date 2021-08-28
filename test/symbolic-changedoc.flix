use ChangeDoc/Datatypes.{ChangeDoc, ChangeRow, ChangeKey, Instruction, EntityType, ValueState};
use ChangeDoc/Datatypes.ChangeRow.{ChangeRow};

use ChangeDoc/Datatypes.Instruction.{New, Delete, Change};
use ChangeDoc/Datatypes.ChangeKey.{NameKey};
use ChangeDoc/Datatypes.EntityType.{Equi, Floc};
use ChangeDoc/Relations.{Funcloc, Equipment};
use ChangeDoc/BuildRel.{ClassName};


def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    test01();
    test02() |> println;
    0

def test01(): Unit & Impure = 
    ((NameKey(Equi, "x") `Order.compare` NameKey(Equi, "x")) == EqualTo) |> println;
    ((NameKey(Equi, "x") `Order.compare` NameKey(Floc, "x")) == LessThan) |> println;
    ((NameKey(Floc, "x") `Order.compare` NameKey(Equi, "x")) == GreaterThan) |> println;
    ()

def test02(): Result[Unit, String] & Impure =
    use Result.flatMap;
    let changeSource    = System/FilePath.new("G:/work/assets/change-requests/cr8600/cr8600-change-doc-attributes.xlsx");
    let changeDest      = System/FilePath.new("G:/work/assets/change-requests/cr8600/cr8600-report1.xlsx");
    let* patches    = ChangeDoc/Loader.readChangeDoc(changeSource);
    let st1         = ChangeDoc/Interpreter.interpret(patches);
    let _           = st1 |> Map.foreach((k, v) -> Console.printLine("${k} -> ${v}"));
    let relns       = ChangeDoc/Relations.makeChangeRelations(st1);
    let rules       = ChangeDoc/BuildRel.rules();
    let database    = (relns <+> rules<+> ChangeDoc/BuildRel.query1());
    /// Console.printLine("Funcloc...");    
    /// let _           = query database select (x1, x2, x3) from Funcloc(x1, x2, x3) |> Array.foreach(println);
    /// Console.printLine("Equipment...");
    /// let _           = query database select (x1, x2) from Equipment(x1, x2) |> Array.foreach(println);
    Console.printLine("ClassName...");
    let _           = query database select (x1, x2) from ClassName(x1, x2) 
                        |> Array.foreach(println);
    Console.printLine("buildFlocRows...");
    let* _          = ChangeDoc/Report1.buildFlocRows(database)
                        |> perform(Array.foreach(ChangeDoc/Report1.flocRowToString >> Console.printLine))
                        |> ChangeDoc/Report1.writeFlocRows(changeDest);
    Console.printLine("buildEquiRows...");
    let* _          = ChangeDoc/Report1.buildEquiRows(database)
                        |> perform(Array.foreach(ChangeDoc/Report1.equiRowToString >> Console.printLine))
                        |> ChangeDoc/Report1.addEquiRows(changeDest);
    
    let* _          = ChangeDoc/Report1.extractEquiLongTextRows(database)
                        |> ChangeDoc/Report1.addEquiLongTextRows(changeDest);
    let* _          = ChangeDoc/Report1.extractClassFlocRows(database)
                        |> ChangeDoc/Report1.addClassFlocRows(changeDest);
    let* _          = ChangeDoc/Report1.extractClassEquiRows(database)
                        |> ChangeDoc/Report1.addClassEquiRows(changeDest);
    let* _          = ChangeDoc/Report1.extractValuaEquiRows(database)
                        |> ChangeDoc/Report1.addValuaEquiRows(changeDest);
    Console.printLine("Done");
    Ok()



def perform(f: a -> b & ef, x: a): a & ef = 
    let _ = f(x);
    x

