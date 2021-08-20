use ChangeDoc/Datatypes.{ChangeDoc, ChangeRow, ChangeKey, Instruction, EntityType, ValueState};
use ChangeDoc/Datatypes.ChangeRow.{ChangeRow};

use ChangeDoc/Datatypes.Instruction.{New, Delete, Change};
use ChangeDoc/Datatypes.ChangeKey.{NameKey};
use ChangeDoc/Datatypes.EntityType.{Equi, Floc};


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
    let* patches    = ChangeDoc/Loader.readChangeDoc(changeSource);
    let _           = ChangeDoc/Interpreter.interpret(patches) |> Map.foreach((k, v) -> Console.printLine("${k} -> ${v}"));
    Ok()
