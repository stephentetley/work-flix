use System.Error.{Generic};

use AssetLib/S4/FileIO/ClassList/Raw/Datatypes.{SourceType, ClassList, ClassListFile};
use AssetLib/S4/FileIO/ClassList/Raw/Datatypes.SourceType.{FlocClasses, EquiClasses};
use AssetLib/S4/FileIO/ClassList/TransposeRaw.{TransposeRawParams, transposeRawInput};


def flocOutputParams(): TransposeRawParams = 
    { sourceType                = FlocClasses
    , charset                   = Text/Charset.iso_8859_1()
    , characteristicsOutpath    = "G:/work/Projects/assets/facts/floc_characteristics.csv"
    , refinesValuesOutpath      = "G:/work/Projects/assets/facts/floc_refines_values.csv"
    , refinesRangeOutpath       = "G:/work/Projects/assets/facts/floc_refines_range.csv"
    }

def equiOutputParams(): TransposeRawParams = 
    { sourceType                = EquiClasses
    , charset                   = Text/Charset.iso_8859_1()
    , characteristicsOutpath    = "G:/work/Projects/assets/facts/equi_characteristics.csv"
    , refinesValuesOutpath      = "G:/work/Projects/assets/facts/equi_refines_values.csv"
    , refinesRangeOutpath       = "G:/work/Projects/assets/facts/equi_refines_range.csv"
    }

def main(): Result[Unit, System.Error] & Impure =  
    use Result.flatMap;
    let* _ = transposeRawInput("G:/work/Projects/assets/facts/floc-class-export.txt", flocOutputParams());
    let* _ = transposeRawInput("G:/work/Projects/assets/facts/equi-class-export.txt", equiOutputParams());
    Ok()
