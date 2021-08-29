use ChangeDoc/Datatypes.{ChangeDoc, ChangeRow, ChangeKey, Instruction, EntityType, ValueState};
use ChangeDoc/Datatypes.ChangeRow.{ChangeRow};

use ChangeDoc/Datatypes.Instruction.{New, Delete, Change};
use ChangeDoc/Datatypes.ChangeKey.{NameKey};
use ChangeDoc/Datatypes.EntityType.{Equi, Floc};
use ChangeDoc/Relations.{Funcloc, Equipment};
use ChangeDoc/Report1.{Report1Config};


def config(): Report1Config = 
    { changeAttributesExport = System/FilePath.new("G:/work/assets/change-requests/cr8600/cr8600-change-doc-attributes.xlsx")
    , flocChangeRequestExport = System/FilePath.new("G:/work/assets/change-requests/cr8600/cr8600-floc.xlsx")
    , flocClassList = System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt")
    , equiClassList = System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt")
    , outputPath = System/FilePath.new("G:/work/assets/change-requests/cr8600/cr8600-report1.xlsx")
    }

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    ChangeDoc/Report1.report1(config()) |> println;
    0
