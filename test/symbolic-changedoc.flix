use ChangeDoc/Datatypes.{ChangeDoc, ChangeRow, ChangeKey, Instruction, EntityType, ValueState};
use ChangeDoc/Datatypes.ChangeRow.{ChangeRow};

use ChangeDoc/Datatypes.Instruction.{New, Delete, Change};
use ChangeDoc/Datatypes.ChangeKey.{NameKey};
use ChangeDoc/Datatypes.EntityType.{Equi, Floc};
use ChangeDoc/Relations.{Funcloc, Equipment};
use ChangeDoc/Report1.{Report1Config};



def config(): Report1Config = 
    { flocClassList = System/FilePath.new("G:/work/assets/facts/003-floc-class-list.txt")
    , equiClassList = System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt")
    , changeAttributesExport = System/FilePath.new("G:/work/assets/change-requests/cr9231-hudub-wwp/hudub-wwp-changeattrs.xlsx")
    , flocTabExport = Some(System/FilePath.new("G:/work/assets/change-requests/cr9231-hudub-wwp/hudub-wwp-floctab.xlsx"))
    , equiTabExport = Some(System/FilePath.new("G:/work/assets/change-requests/cr9231-hudub-wwp/hudub-wwp-equitab.xlsx"))
    , outputPath = System/FilePath.new("G:/work/assets/change-requests/output/hudub-report2.xlsx")
    }

def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running... ${Time/LocalTime.now()}");
    ChangeDoc/Report1.report1(config()) |> println;
    0
