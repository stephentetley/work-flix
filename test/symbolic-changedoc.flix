use ChangeDoc/Datatypes.{ChangeDoc, ChangeRow, ChangeKey, Instruction, ValueState};
use ChangeDoc/Datatypes.ChangeRow.{ChangeRow};

use ChangeDoc/Datatypes.Instruction.{New, Delete, Change};
use ChangeDoc/Datatypes.ChangeKey.{EquiNameKey, FlocNameKey};


def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    test01();
    test02();
    0

def test01(): Unit & Impure = 
    ((EquiNameKey("x") `Order.compare` EquiNameKey("x")) == EqualTo) |> println;
    ((EquiNameKey("x") `Order.compare` FlocNameKey("x")) == LessThan) |> println;
    ((FlocNameKey("x") `Order.compare` EquiNameKey("x")) == GreaterThan) |> println;
    ()

def test02(): Result[Unit, String] & Impure =
    use Result.flatMap;
    let src         = {path = System/FilePath.new("G:/work/assets/change-requests/cr8600/cr8600-change-doc-attributes.xlsx")
                        , sheet = "Data"};
    let* patches    = ChangeDoc/Loader.readChangeDoc(src);
    let _           = ChangeDoc/Interpret.interpret(patches) |> println;
    Ok()
    