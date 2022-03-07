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
    

namespace AssetLib/FileIO/S4/UxlFile/XlsxReader {

    use Functor.{<$>};
    use Applicative.{<*>};

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/FileIO/S4/UxlFile/Datatypes.{ChangeRequestDetails,
        FunctionalLocationData, FlMultilingualText, FlClassification, 
        EquipmentData, EqMultilingualText, EqClassification};

    /// Change Request Details

    pub def readChangeRequestDetailsMocr(): SheetReader[List[ChangeRequestDetails]] = 
        use SheetIO/SheetReader.{flatMap, point, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("Change Request Details");
        let* xs     = namedRowsFrom({headerIndex = 4, start = 6}, getChangeRequestDetailsMocr(), s1);
        point(xs)

    def getChangeRequestDetailsMocr(): NamedRowEvaluator[ChangeRequestDetails] = 
        use SheetIO/NamedRowEvaluator.{optional, getContentNamed};
        ((x1, x2, x3, x4, x5) -> 
                { description           = x1
                , changeRequestType     = x2
                , flFunctionalLocation  = x3
                , eqEquipment           = x4
                , processRequester      = x5
                })
            <$> getContentNamed("Text")                 /// description
            <*> getContentNamed("CrType")               /// changeRequestType
            <*> getContentNamed("Funcloc")              /// flFunctionalLocation
            <*> getContentNamed("Equi")                 /// eqEquipment
            <*> getContentNamed("ZzprocessRequester")   /// processRequester
        


    /// Functional Location Data

    pub def readFunctionalLocationData(): SheetReader[List[FunctionalLocationData]] = 
        use SheetIO/SheetReader.{flatMap, point, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("Functional Location Data");
        let* xs     = namedRowsFrom({headerIndex = 4, start = 6}, getFunctionalLocationData(), s1);
        point(xs)

    def getFunctionalLocationData(): NamedRowEvaluator[FunctionalLocationData] = 
        use SheetIO/NamedRowEvaluator.{getContentNamed, getInt32Named, optional};
        use AssetLib/Base/S4/SheetIOUtils.{getS4BoolNamed, getS4LocalDateNamed};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17) ->
                { functionalLocation    = x1
                , maskedFuncLoc         = x2
                , description           = x3                
                , functLocCat           = x4
                , strIndicator          = x5
                , objectType            = x6
                , startupDate           = x7
                , constructYear         = x8
                , constructMth          = x9
                , maintPlant            = x10
                , companyCode           = x11
                , coArea                = x12
                , planningPlant         = x13
                , position              = x14
                , supFunctLoc           = x15
                , equipInstall          = x16
                , statusOfObject        = x17
                })
            <$> getContentNamed("Funcloc")              /// functionalLocation
            <*> getContentNamed("FlocRef")              /// maskedFuncLoc
            <*> getContentNamed("Txtmi")                /// description
            <*> getInt32Named("Fltyp")                  /// functLocCat
            <*> getContentNamed("TplkzFlc")             /// strIndicator
            <*> getContentNamed("Eqart")                /// objectType
            <*> getS4LocalDateNamed("Inbdt")            /// startupDate
            <*> getInt32Named("Baujj")                              /// constructYear
            <*> getPaddedInt32Named("BaummEqi")                     /// constructMth
            <*> getInt32Named("SwerkFl")                /// maintPlant
            <*> getInt32Named("Bukrsfloc")              /// companyCode
            <*> getInt32Named("KokrFloc")               /// coArea
            <*> getInt32Named("PlntFloc")            /// planningPlant
            <*> optional(getInt32Named("Posnr"))        /// Position
            <*> getContentNamed("Tplma")                /// supFunctLoc
            <*> getS4BoolNamed("Iequi")                 /// equipInstall
            <*> getContentNamed("Sttxu")                /// statusOfObject
   
    


    /// FL-Multilingual Text

    pub def readFlMultilingualText(): SheetReader[List[FlMultilingualText]] = 
        use SheetIO/SheetReader.{flatMap, point, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("FL-Multilingual Text");
        let* xs     = namedRowsFrom({headerIndex = 4, start = 6}, getFlMultilingualText(), s1);
        point(xs)

    def getFlMultilingualText(): NamedRowEvaluator[FlMultilingualText] = 
        use SheetIO/NamedRowEvaluator.{getContentNamed};
        use AssetLib/Base/S4/SheetIOUtils.{getS4BoolNamed};
        ((x1, x2, x3, x4, x5) -> 
                { functionalLocation = x1
                , deleteIndicator = x2
                , language = x3
                , description = x4
                , longText = x5
                })
            <$> getContentNamed("Funcloc")
            <*> getS4BoolNamed("DeleteFlag")
            <*> getContentNamed("Langucode")
            <*> getContentNamed("Pltxt")
            <*> getContentNamed("FlLtxt")

    /// FL-Classification

    pub def loadFlClassification(path: System.FilePath): Result[List[FlClassification], String] & Impure =   
        SheetIO/SheetReader.runXlsx(readFlClassification(), path)

    pub def readFlClassification(): SheetReader[List[FlClassification]] = 
        use SheetIO/SheetReader.{flatMap, point, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("FL-Classification");
        let* xs     = namedRowsFrom({headerIndex = 4, start = 6}, getFlClassification(), s1);
        point(xs)


    def getFlClassification(): NamedRowEvaluator[FlClassification] = 
        use SheetIO/NamedRowEvaluator.{getContentNamed};
        use AssetLib/Base/S4/SheetIOUtils.{getS4BoolNamed};
        ((x1, x2, x3, x4, x5, x6, x7) -> 
                { functionalLocation    = x1
                , deletionInd           = x2
                , classType             = x3
                , className             = x4
                , characteristicName    = x5
                , charValue             = x6
                , charDeletionInd       = x7
                })
            <$> getContentNamed("FunclocCl")
            <*> getS4BoolNamed("DeleteCl")
            <*> getContentNamed("ClasstypeCl")
            <*> getContentNamed("ClassCl")
            <*> getContentNamed("CharidExtForm")
            <*> getContentNamed("Atwrt")
            <*> getS4BoolNamed("DeleteCh")

    /// Equipment Data
    pub def loadEquipmentDataMocr(path: System.FilePath): Result[List[EquipmentData], String] & Impure =   
        SheetIO/SheetReader.runXlsx(readEquipmentDataMocr(), path)

    pub def readEquipmentDataMocr(): SheetReader[List[EquipmentData]] = 
        use SheetIO/SheetReader.{flatMap, point, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("Equipment Data");
        let* xs     = namedRowsFrom({headerIndex = 4, start = 6}, getEquipmentDataMocr(), s1);
        point(xs)

    def getEquipmentDataMocr(): NamedRowEvaluator[EquipmentData] = 
        use SheetIO/NamedRowEvaluator.{getContentNamed, 
            getOptionInt32Named, getInt32Named, getFloat64Named, optional};
        use AssetLib/Base/S4/SheetIOUtils.{getS4LocalDateNamed};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, 
            x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27) -> 
                { equiId            = x1
                , equipCategory     = x2
                , description       = x3
                , validFrom         = x4
                , objectType        = x5
                , grossWeight       = x6
                , unitOfWeight      = x7
                , startupDate       = x8
                , manufacturer      = x9
                , modelNumber       = x10
                , manufPartNo       = x11
                , manufSerialNo     = x12
                , constructYear     = x13
                , constructMth      = x14
                , maintPlant        = x15                
                , workCenter        = x16
                , companyCode       = x17
                , coArea            = x18
                , planningPlant     = x19
                , mainWorkCenter    = x20
                , plantWorkCenter   = x21
                , functionalLoc     = x22
                , superordEquip     = x23
                , position          = x24
                , techIdentNo       = x25
                , statusProfile     = x26
                , statusOfAnObject  = x27
                })
            <$> getContentNamed("Equi")                             /// equiId
            <*> getContentNamed("Eqtyp")                            /// equipCategory
            <*> getContentNamed("Txtmi")                            /// description
            <*> getS4LocalDateNamed("DataEeqz")                     /// validFrom
            <*> getContentNamed("EqartEqu")                         /// objectType
            <*> optional(getFloat64Named("Brgew"))                  /// grossWeight
            <*> getContentNamed("Gewei")                            /// unitOfWeight
            <*> getS4LocalDateNamed("Inbdt")                        /// startupDate
            <*> getContentNamed("Herst")                            /// manufacturer
            <*> getContentNamed("Typbz")                            /// modelNumber
            <*> getContentNamed("MapaEeqz")                         /// manufPartNo
            <*> getContentNamed("Serge")                            /// manufSerialNo
            <*> getInt32Named("Baujj")                              /// constructYear
            <*> getPaddedInt32Named("BaummEqi")                     /// constructMth
            <*> getInt32Named("SwerEilo")                           /// maintPlant 
            <*> getContentNamed("ArbpEilo")                         /// workCenter
            <*> getInt32Named("BukrEilo")                           /// companyCode
            <*> getInt32Named("KokrEilo")                           /// coArea
            <*> getInt32Named("PplaEeqz")                           /// planningPlant
            <*> getContentNamed("ArbpEeqz")                         /// mainWorkCenter
            <*> getInt32Named("WergwEqi")                           /// plantWorkCenter
            <*> getContentNamed("TplnEilo")                         /// functionalLoc
            <*> getContentNamed("HequEeqz")                         /// superordEquip
            <*> optional(getInt32Named("HeqnEeqz"))                 /// position
            <*> getContentNamed("TidnEeqz")                          /// techIdentNo
            <*> getContentNamed("StsmEqui")                          /// statusProfile
            <*> getContentNamed("UstwEqui")                          /// statusOfAnObject


    /// EQ-Multilingual Text

    pub def readEqMultilingualTextMocr(): SheetReader[List[EqMultilingualText]] = 
        use SheetIO/SheetReader.{flatMap, point, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("EQ-Multilingual Text");
        let* xs     = namedRowsFrom({headerIndex = 4, start = 6}, getEqMultilingualTextMocr(), s1);
        point(xs)

    def getEqMultilingualTextMocr(): NamedRowEvaluator[EqMultilingualText] = 
        use SheetIO/NamedRowEvaluator.{getContentNamed};
        use AssetLib/Base/S4/SheetIOUtils.{getS4BoolNamed};
        ((x1, x2, x3, x4, x5) -> 
                { equiId = x1
                , deleteIndicator = x2
                , language = x3
                , description = x4
                , longText = x5
                })
            <$> getContentNamed("Equi")
            <*> getS4BoolNamed("DeleteFlag")
            <*> getContentNamed("Langucode")
            <*> getContentNamed("Shortxt")
            <*> getContentNamed("EqLtxt")

    /// EQ-Classification
    
    pub def loadEqClassificationMocr(path: System.FilePath): Result[List[EqClassification], String] & Impure =   
        SheetIO/SheetReader.runXlsx(readEqClassificationMocr(), path)

    pub def readEqClassificationMocr(): SheetReader[List[EqClassification]] = 
        use SheetIO/SheetReader.{flatMap, point, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("EQ-Classification");
        let* xs     = namedRowsFrom({headerIndex = 4, start = 6}, getEqClassificationMocr(), s1);
        point(xs)

    def getEqClassificationMocr(): NamedRowEvaluator[EqClassification] = 
        use SheetIO/NamedRowEvaluator.{getContentNamed};
        use AssetLib/Base/S4/SheetIOUtils.{getS4BoolNamed};
        ((x1, x2, x3, x4, x5, x6, x7) -> 
                { equiId                = x1
                , deleteInd             = x2 
                , classType             = x3
                , className             = x4
                , characteristicName    = x5 
                , charValue             = x6
                , charDeleteInd         = x7
                })
            <$> getContentNamed("EquiCl")
            <*> getS4BoolNamed("DeleteCl")
            <*> getContentNamed("ClasstypeCl")
            <*> getContentNamed("ClassCl")
            <*> getContentNamed("CharidExtForm")
            <*> getContentNamed("Atwrt")
            <*> getS4BoolNamed("DeleteCh")



    def getPaddedInt32Named(label: String): NamedRowEvaluator[Int32] = 
        use SheetIO/NamedRowEvaluator.{flatMap, getStringNamed, liftActionResult};
        let* s = getStringNamed(label);
        liftActionResult(_ -> Int32.fromString(s) as & Impure)

}
