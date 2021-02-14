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
    
///
/// TODO...
/// Needs adapting for "update" data - reading the `Functional Location Data` and `Equipment Data` tabs.
/// 


namespace AssetLib/S4/FileIO/UxlFile/XlsxReader {


    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/S4/FileIO/UxlFile/Datatypes.{ChangeRequestDetails,
        FunctionalLocationData, FlMultilingualText, FlClassification, 
        EquipmentData, EqMultilingualText, EqClassification};

    /// Change Request Details

    pub def readChangeRequestDetails(): SheetReader[List[ChangeRequestDetails]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("EQ-Classification");
        let* xs     = namedRowsFrom(s1, 4, 6, getChangeRequestDetails());
        return(xs)

    def getChangeRequestDetails(): NamedRowEvaluator[ChangeRequestDetails] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5) -> 
                { description           = x1
                , changeRequestType     = x2
                , flFunctionalLocation  = x3
                , eqEquipment           = x4
                , processRequester      = x5
                })
            <&> getContentNamed("Text")                 /// description
            <*> getContentNamed("CrType")               /// changeRequestType
            <*> getContentNamed("Funcloc")              /// flFunctionalLocation
            <*> getContentNamed("Equi")                 /// eqEquipment
            <*> getContentNamed("ZzprocessRequester")   /// processRequester
        


    /// Functional Location Data

    pub def readFunctionalLocationData(): SheetReader[List[FunctionalLocationData]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("Functional Location Data");
        let* xs     = namedRowsFrom(s1, 4, 6, getFunctionalLocationData());
        return(xs)

    def getFunctionalLocationData(): NamedRowEvaluator[FunctionalLocationData] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed, getInt32Named};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use AssetLib/S4/Base/SheetIOUtils.{getS4BoolNamed, getS4LocalDateNamed};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14) ->
                { functionalLocation    = x1
                , maskedFuncLoc         = x2
                , description           = x3                
                , functLocCat           = x4
                , strIndicator          = x5
                , objectType            = x6
                , startupDate           = x7
                , maintPlant            = x8
                , companyCode           = x9
                , coArea                = x10
                , supFunctLoc           = x11
                , equipInstall          = x12
                , statusProfile         = x13
                , userStatus            = x14
                })
            <&> getContentNamed("Funcloc")              /// functionalLocation
            <*> getContentNamed("FlocRef")              /// maskedFuncLoc
            <*> getContentNamed("Txtmi")                /// description
            <*> getInt32Named("Fltyp")                  /// functLocCat
            <*> getContentNamed("TplkzFlc")             /// strIndicator
            <*> getContentNamed("Eqart")                /// objectType
            <*> getS4LocalDateNamed("Inbdt")            /// startupDate
            <*> getInt32Named("SwerkFl")                /// maintPlant
            <*> getInt32Named("Bukrsfloc")              /// companyCode
            <*> getInt32Named("KokrFloc")               /// coArea
            <*> getContentNamed("Tplma")                /// supFunctLoc
            <*> getS4BoolNamed("Iequi")                 /// equipInstall
            <*> getContentNamed("StsmFloc")             /// statusProfile
            <*> getContentNamed("Sttxu")                /// userStatus
   
    


    /// FL-Multilingual Text

    pub def readFlMultilingualText(): SheetReader[List[FlMultilingualText]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("FL-Multilingual Text");
        let* xs     = namedRowsFrom(s1, 4, 6, getFlMultilingualText());
        return(xs)

    def getFlMultilingualText(): NamedRowEvaluator[FlMultilingualText] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use AssetLib/S4/Base/SheetIOUtils.{getS4BoolNamed};
        ((x1, x2, x3, x4, x5) -> 
                { functionalLocation = x1
                , deleteIndicator = x2
                , language = x3
                , description = x4
                , longText = x5
                })
            <&> getContentNamed("Funcloc")
            <*> getS4BoolNamed("DeleteFlag")
            <*> getContentNamed("Langucode")
            <*> getContentNamed("Pltxt")
            <*> getContentNamed("FlLtxt")

    /// FL-Classification

    pub def loadFlClassification(path: System.FilePath): Result[List[FlClassification], String] & Impure =   
        SheetIO/SheetReader.runXlsx(readFlClassification(), path)

    pub def readFlClassification(): SheetReader[List[FlClassification]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("FL-Classification");
        let* xs     = namedRowsFrom(s1, 4, 6, getFlClassification());
        return(xs)


    def getFlClassification(): NamedRowEvaluator[FlClassification] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use AssetLib/S4/Base/SheetIOUtils.{getS4BoolNamed};
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
            <&> getContentNamed("FunclocCl")
            <*> getS4BoolNamed("DeleteCl")
            <*> getContentNamed("ClasstypeCl")
            <*> getContentNamed("ClassCl")
            <*> getContentNamed("Clstatus1Cl")
            <*> getContentNamed("CharidExtForm")
            <*> getContentNamed("Atwrt")
            <*> getS4BoolNamed("DeleteCh")

    /// Equipment Data
    pub def loadEquipmentData(path: System.FilePath): Result[List[EquipmentData], String] & Impure =   
        SheetIO/SheetReader.runXlsx(readEquipmentData(), path)

    pub def readEquipmentData(): SheetReader[List[EquipmentData]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("Equipment Data");
        let* xs     = namedRowsFrom(s1, 4, 6, getEquipmentData());
        return(xs)

    def getEquipmentData(): NamedRowEvaluator[EquipmentData] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed, 
            getOptionInt32Named, getInt32Named, getFloat64Named, optional};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use AssetLib/S4/Base/SheetIOUtils.{getS4LocalDateNamed};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, 
            x15, x16, x17, x18, x19, x20, x21, x22, x23) -> 
                { equiId            = x1
                , equipCategory     = x2
                , description       = x3
                , objectType        = x4
                , grossWeight       = x5
                , unitOfWeight      = x6
                , startupDate       = x7
                , manufacturer      = x8
                , modelNumber       = x9
                , manufPartNo       = x10
                , manufSerialNo     = x11
                , constructYear     = x12
                , constructMth      = x13
                , maintPlant        = x14
                , companyCode       = x15
                , coArea            = x16
                , planningPlant     = x17
                , functionalLoc     = x18
                , superordEquip     = x19
                , position          = x20
                , techIdentNo       = x21
                , statusProfile     = x22
                , statusOfAnObject  = x23
                })
            <&> getContentNamed("Equi")                             /// equiId
            <*> getContentNamed("Eqtyp")                            /// equipCategory
            <*> getContentNamed("Txtmi")                            /// description
            <*> getContentNamed("EqartEqu")                         /// objectType
            <*> optional(getFloat64Named("Brgew"))                  /// grossWeight
            <*> getContentNamed("Gewei")                            /// unitOfWeight
            <*> getS4LocalDateNamed("Inbdt")                          /// startupDate
            <*> getContentNamed("Herst")                             /// manufacturer
            <*> getContentNamed("Typbz")                             /// modelNumber
            <*> getContentNamed("MapaEeqz")           /// manufPartNo
            <*> getContentNamed("Serge")                             /// manufSerialNo
            <*> getInt32Named("Baujj")                              /// constructYear
            <*> getPaddedInt32Named("BaummEqi")                     /// constructMth
            <*> getInt32Named("SwerEilo")                           /// maintPlant 
            <*> getInt32Named("BukrEilo")                           /// companyCode
            <*> getInt32Named("KokrEilo")                           /// coArea
            <*> getInt32Named("PplaEeqz")                           /// planningPlant
            <*> getContentNamed("TplnEilo")                          /// functionalLoc
            <*> getContentNamed("HequEeqz")                          /// superordEquip
            <*> getOptionInt32Named("HeqnEeqz")                     /// position
            <*> getContentNamed("TidnEeqz")                          /// techIdentNo
            <*> getContentNamed("StsmEqui")                          /// statusProfile
            <*> getContentNamed("UstwEqui")                          /// statusOfAnObject


    /// EQ-Multilingual Text

    pub def readEqMultilingualText(): SheetReader[List[EqMultilingualText]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("EQ-Multilingual Text");
        let* xs     = namedRowsFrom(s1, 4, 6, getEqMultilingualText());
        return(xs)

    def getEqMultilingualText(): NamedRowEvaluator[EqMultilingualText] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use AssetLib/S4/Base/SheetIOUtils.{getS4BoolNamed};
        ((x1, x2, x3, x4, x5) -> 
                { equiId = x1
                , deleteIndicator = x2
                , language = x3
                , description = x4
                , longText = x5
                })
            <&> getContentNamed("Equi")
            <*> getS4BoolNamed("DeleteFlag")
            <*> getContentNamed("Langucode")
            <*> getContentNamed("Shortxt")
            <*> getContentNamed("EqLtxt")

    /// EQ-Classification
    
    pub def loadEqClassification(path: System.FilePath): Result[List[EqClassification], String] & Impure =   
        SheetIO/SheetReader.runXlsx(readEqClassification(), path)

    pub def readEqClassification(): SheetReader[List[EqClassification]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("EQ-Classification");
        let* xs     = namedRowsFrom(s1, 4, 6, getEqClassification());
        return(xs)

    def getEqClassification(): NamedRowEvaluator[EqClassification] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use AssetLib/S4/Base/SheetIOUtils.{getS4BoolNamed};
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
            <&> getContentNamed("EquiCl")
            <*> getS4BoolNamed("DeleteCl")
            <*> getContentNamed("ClasstypeCl")
            <*> getContentNamed("ClassCl")
            <*> getContentNamed("Clstatus1Cl")
            <*> getContentNamed("CharidExtForm")
            <*> getContentNamed("Atwrt")
            <*> getS4BoolNamed("DeleteCh")



    def getPaddedInt32Named(label: String): NamedRowEvaluator[Int32] = 
        use SheetIO/NamedRowEvaluator.{flatMap, getStringNamed, liftActionResult};
        let* s = getStringNamed(label);
        liftActionResult(_ -> Int32.fromString(s) as & Impure)

        


}