/*
 * Copyright 2020 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
    

namespace AssetLib/S4/FileIO/UxlFile/XlsxReader {


    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/S4/FileIO/UxlFile/Datatypes.{FlClassification, EqClassification};

    pub def loadFlClassifications(path: System.FilePath): Result[List[FlClassification], System.Error] & Impure =   
        SheetIO/SheetReader.runXlsx(readFlClassifications(), path)

    pub def readFlClassifications(): SheetReader[List[FlClassification]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheet, maximalNamedRows};      
        let* s1     = getSheet("FL-Classification");
        let* xs     = maximalNamedRows(s1, 4, 6, evalFlClassification());
        return(xs)


    def evalFlClassification(): NamedRowEvaluator[FlClassification] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getStringNamed, 
                getStringNamedWithDefault, getInt32Named};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8) -> 
                { functionalLocation    = x1
                , deletionInd           = x2
                , classType             = x3
                , className             = x4
                , status                = x5
                , characteristicName    = x6
                , charValue             = x7
                , charDeletionInd       = x8
                })
            <&> getStringNamed("FunclocCl")
            <*> getBoolNamed("DeleteCl")
            <*> getStringNamed("ClasstypeCl")
            <*> getStringNamed("ClassCl")
            <*> getStatusNamed("Clstatus1Cl")
            <*> getStringNamed("CharidExtForm")
            <*> getStringNamedWithDefault("Atwrt", "")
            <*> getBoolNamed("DeleteCh")


    pub def loadEqClassifications(path: System.FilePath): Result[List[EqClassification], System.Error] & Impure =   
        SheetIO/SheetReader.runXlsx(readEqClassifications(), path)

    pub def readEqClassifications(): SheetReader[List[EqClassification]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheet, maximalNamedRows};      
        let* s1     = getSheet("EQ-Classification");
        let* xs     = maximalNamedRows(s1, 4, 6, evalEqClassification());
        return(xs)

    def evalEqClassification(): NamedRowEvaluator[EqClassification] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getStringNamed, 
                getStringNamedWithDefault, getInt32Named};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8) -> 
                { equiId                = x1
                , deleteInd             = x2 
                , classType             = x3
                , className             = x4
                , status                = x5
                , characteristicName    = x6 
                , charValue             = x7
                , charDeleteInd         = x8
                })
            <&> getStringNamed("EquiCl")
            <*> getBoolNamed("DeleteCl")
            <*> getStringNamed("ClasstypeCl")
            <*> getStringNamed("ClassCl")
            <*> getStatusNamed("Clstatus1Cl")
            <*> getStringNamed("CharidExtForm")
            <*> getStringNamedWithDefault("Atwrt", "")
            <*> getBoolNamed("DeleteCh")


    /// Allows blank...
    def getBoolNamed(label: String): NamedRowEvaluator[Bool] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getStringNamedWithDefault};
        let* x = getStringNamedWithDefault(label, "");
        if (x == "X") return(true) else return(false)

    def getStatusNamed(label: String): NamedRowEvaluator[String] =        
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, alt, getInt32Named, getStringNamed};
        alt( map(Int32.toString, getInt32Named(label))
            , getStringNamed(label)
            )

}