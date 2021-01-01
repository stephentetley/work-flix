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
        CreateFunctionalLocationData, FlMultilingualText, FlClassification, 
        CreateEquipmentData, EqMultilingualText, EqClassification};

    /// Change Request Details

    pub def readChangeRequestDetails(): SheetReader[List[ChangeRequestDetails]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("EQ-Classification");
        let* xs     = namedRowsFrom(s1, 4, 6, getChangeRequestDetails());
        return(xs)

    def getChangeRequestDetails(): NamedRowEvaluator[ChangeRequestDetails] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getStringNamed, 
                getStringNamedWithDefault, getInt32Named};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5) -> 
                { description           = x1
                , changeRequestType     = x2
                , flFunctionalLocation  = x3
                , eqEquipment           = x4
                , processRequester      = x5
                })
            <&> getStringNamed("Text")                  /// description
            <*> getStringNamed("CrType")                /// changeRequestType
            <*> getStringNamed("Funcloc")               /// flFunctionalLocation
            <*> getStringNamed("Equi")                  /// eqEquipment
            <*> getStringNamed("ZzprocessRequester")    /// processRequester
        


    /// Functional Location Data

    pub def readFunctionalLocationData(): SheetReader[List[CreateFunctionalLocationData]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("Functional Location Data");
        let* xs     = namedRowsFrom(s1, 4, 6, getFunctionalLocationData());
        return(xs)

    def getFunctionalLocationData(): NamedRowEvaluator[CreateFunctionalLocationData] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getStringNamed, 
                getStringNamedWithDefault, getInt32Named};
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
            <&> getStringNamed("Funcloc")               /// functionalLocation
            <*> getStringNamed("FlocRef")               /// maskedFuncLoc
            <*> getStringNamed("Txtmi")                 /// description
            <*> getInt32Named("Fltyp")                  /// functLocCat
            <*> getStringNamed("TplkzFlc")              /// strIndicator
            <*> getStringNamed("Eqart")                 /// objectType
            <*> getS4LocalDateNamed("Inbdt")            /// startupDate
            <*> getInt32Named("SwerkFl")                /// maintPlant
            <*> getInt32Named("Bukrsfloc")              /// companyCode
            <*> getInt32Named("KokrFloc")               /// coArea
            <*> getStringNamed("Tplma")                 /// supFunctLoc
            <*> getS4BoolNamed("Iequi")                 /// equipInstall
            <*> getStringNamed("StsmFloc")              /// statusProfile
            <*> getStringNamed("Sttxu")                 /// userStatus
   
    


    /// FL-Multilingual Text

    pub def readFlMultilingualText(): SheetReader[List[FlMultilingualText]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("FL-Multilingual Text");
        let* xs     = namedRowsFrom(s1, 4, 6, getFlMultilingualText());
        return(xs)

    def getFlMultilingualText(): NamedRowEvaluator[FlMultilingualText] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getStringNamed, 
                getStringNamedWithDefault, getInt32Named};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use AssetLib/S4/Base/SheetIOUtils.{getS4BoolNamed};
        ((x1, x2, x3, x4, x5) -> 
                { functionalLocation = x1
                , deleteIndicator = x2
                , language = x3
                , description = x4
                , longText = x5
                })
            <&> getStringNamed("Funcloc")
            <*> getS4BoolNamed("DeleteFlag")
            <*> getStringNamed("Langucode")
            <*> getStringNamed("Pltxt")
            <*> getStatusNamed("FlLtxt")

    /// FL-Classification

    pub def loadFlClassification(path: System.FilePath): Result[List[FlClassification], String] & Impure =   
        SheetIO/SheetReader.runXlsx(readFlClassification(), path)

    pub def readFlClassification(): SheetReader[List[FlClassification]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("FL-Classification");
        let* xs     = namedRowsFrom(s1, 4, 6, getFlClassification());
        return(xs)


    def getFlClassification(): NamedRowEvaluator[FlClassification] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getStringNamed, 
                getStringNamedWithDefault, getInt32Named};
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
            <&> getStringNamed("FunclocCl")
            <*> getS4BoolNamed("DeleteCl")
            <*> getStringNamed("ClasstypeCl")
            <*> getStringNamed("ClassCl")
            <*> getStatusNamed("Clstatus1Cl")
            <*> getStringNamed("CharidExtForm")
            <*> getStringNamedWithDefault("Atwrt", "")
            <*> getS4BoolNamed("DeleteCh")

    /// Equipment Data
    pub def loadEquipmentData(path: System.FilePath): Result[List[CreateEquipmentData], String] & Impure =   
        SheetIO/SheetReader.runXlsx(readEquipmentData(), path)

    pub def readEquipmentData(): SheetReader[List[CreateEquipmentData]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("Equipment Data");
        let* xs     = namedRowsFrom(s1, 4, 6, getEquipmentData());
        return(xs)

    def getEquipmentData(): NamedRowEvaluator[CreateEquipmentData] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getStringNamed, 
                getStringNamedWithDefault, getOptionInt32Named, getInt32Named, getFloat64Named, optional};
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
            <&> getStringNamed("Equi")                              /// equiId
            <*> getStringNamed("Eqtyp")                             /// equipCategory
            <*> getStringNamed("Txtmi")                             /// description
            <*> getStringNamed("EqartEqu")                          /// objectType
            <*> optional(getFloat64Named("Brgew"))                  /// grossWeight
            <*> getStringNamedWithDefault("Gewei", "")              /// unitOfWeight
            <*> getS4LocalDateNamed("Inbdt")                          /// startupDate
            <*> getStringNamed("Herst")                             /// manufacturer
            <*> getStringNamed("Typbz")                             /// modelNumber
            <*> getStringNamedWithDefault("MapaEeqz", "")           /// manufPartNo
            <*> getStringNamed("Serge")                             /// manufSerialNo
            <*> getInt32Named("Baujj")                              /// constructYear
            <*> getPaddedInt32Named("BaummEqi")                     /// constructMth
            <*> getInt32Named("SwerEilo")                           /// maintPlant 
            <*> getInt32Named("BukrEilo")                           /// companyCode
            <*> getInt32Named("KokrEilo")                           /// coArea
            <*> getInt32Named("PplaEeqz")                           /// planningPlant
            <*> getStringNamed("TplnEilo")                          /// functionalLoc
            <*> getStringNamed("HequEeqz")                          /// superordEquip
            <*> getOptionInt32Named("HeqnEeqz")                     /// position
            <*> getStringNamed("TidnEeqz")                          /// techIdentNo
            <*> getStringNamed("StsmEqui")                          /// statusProfile
            <*> getStringNamed("UstwEqui")                          /// statusOfAnObject


    /// EQ-Multilingual Text

    pub def readEqMultilingualText(): SheetReader[List[EqMultilingualText]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("EQ-Multilingual Text");
        let* xs     = namedRowsFrom(s1, 4, 6, getEqMultilingualText());
        return(xs)

    def getEqMultilingualText(): NamedRowEvaluator[EqMultilingualText] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getStringNamed, 
                getStringNamedWithDefault, getInt32Named};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use AssetLib/S4/Base/SheetIOUtils.{getS4BoolNamed};
        ((x1, x2, x3, x4, x5) -> 
                { equiId = x1
                , deleteIndicator = x2
                , language = x3
                , description = x4
                , longText = x5
                })
            <&> getStringNamed("Equi")
            <*> getS4BoolNamed("DeleteFlag")
            <*> getStringNamed("Langucode")
            <*> getStringNamed("Shortxt")
            <*> getStatusNamed("EqLtxt")

    /// EQ-Classification
    
    pub def loadEqClassification(path: System.FilePath): Result[List[EqClassification], String] & Impure =   
        SheetIO/SheetReader.runXlsx(readEqClassification(), path)

    pub def readEqClassification(): SheetReader[List[EqClassification]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom};      
        let* s1     = getSheetNamed("EQ-Classification");
        let* xs     = namedRowsFrom(s1, 4, 6, getEqClassification());
        return(xs)

    def getEqClassification(): NamedRowEvaluator[EqClassification] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getStringNamed, 
                getStringNamedWithDefault, getInt32Named};
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
            <&> getStringNamed("EquiCl")
            <*> getS4BoolNamed("DeleteCl")
            <*> getStringNamed("ClasstypeCl")
            <*> getStringNamed("ClassCl")
            <*> getStatusNamed("Clstatus1Cl")
            <*> getStringNamed("CharidExtForm")
            <*> getStringNamedWithDefault("Atwrt", "")
            <*> getS4BoolNamed("DeleteCh")




    def getStatusNamed(label: String): NamedRowEvaluator[String] =  
        use SheetIO/NamedRowEvaluator.{flatMap, map, alt, getInt32Named, getStringNamed};
        alt( map(Int32.toString, getInt32Named(label))
            , getStringNamed(label)
            )

    def getPaddedInt32Named(label: String): NamedRowEvaluator[Int32] = 
        use SheetIO/NamedRowEvaluator.{flatMap, getStringNamed, liftActionResult};
        let* s = getStringNamed(label);
        liftActionResult(_ -> Int32.fromString(s) as & Impure)

        

    /// def logged(tag: String, fn: NamedRowEvaluator[String]): NamedRowEvaluator[String] = 
    ///     use SheetIO/NamedRowEvaluator.{flatMap, return, liftAction};
    ///     let* ans = fn;
    ///     let* _ = liftAction(_ -> Console.printLine("${tag}: ${ans}"));
    ///     return(ans)

///    def loggedInt32(tag: String, fn: NamedRowEvaluator[Int32]): NamedRowEvaluator[Int32] = 
///         use SheetIO/NamedRowEvaluator.{flatMap, return, liftAction};
///         let* ans = fn;
///         let* _ = liftAction(_ -> Console.printLine("${tag}: ${Int32.toString(ans)}"));
///         return(ans)


}