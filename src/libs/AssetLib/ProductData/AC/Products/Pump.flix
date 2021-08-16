/*
 * Copyright 2021 Stephen Tetley
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

namespace AssetLib/ProductData/AC/Products/Pump {

    use SheetIO.NamedRowEvaluator;
    use SheetIO/Reader.XlsxSource;

    use AssetLib/S4Lite/Datatypes.{UxlSource, SLEquipment, SLEquiCharacteristic, SLDatatype};
    use AssetLib/S4Lite/Datatypes.SLDatatype.{Character, NumericInt, NumericFloat};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, 
        ConditionGrade, LoadingFactor, PerformanceGrade, SurveyYear, 
        PumpFlow, DutyHead, ImpellerType};
    use AssetLib/GenS4.GenEquiMonad;
    use AssetLib/GenS4/GenEquiMonad.EquiRef;
    use AssetLib/GenS4/GenEquiMonad.EquiRef.{EquiRef};
    use AssetLib/ProductData/Base/Classification.{ObjectClassification};
    
    /// Base is PUMP (category "M") / PUMS (category "E")
    /// PUMPDI | ...

    
    type alias PumpRow = 
        { description: String
        , className: String
        , pandiTag: String
        , manufacturer: String
        , modelNumber: String
        , specificModel: String
        , manufSerialNumber: String
        , weight: Option[Float64]
        , impellerType: String
        , insulationClass: String
        , ipRating: String
        , installedDesignHeadM: Option[Float64]
        , inletSizeMM: Option[Int32]
        , outletSizeMM: Option[Int32]
        , ratedSpeedRPM: Option[Int32]
        , flowLS: Option[Float64]
        , dateOfInstallation: Option[Time.LocalDate]
        , locationOnSite: String
        , locationInHierarchy: String
        , memoLine: String
        }

    pub def loadPumpRows(src: XlsxSource): Result[List[PumpRow], String] & Impure = 
        SheetIO/Reader.readAllNamedRows(src, evalPumpRow())


    pub def evalPumpRow(): NamedRowEvaluator[PumpRow] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, 
            getInt32Named, getFloat64Named, getLocalDateNamed, optional};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20) -> 
            { description           = x1
            , className             = x2
            , pandiTag              = x3
            , manufacturer          = x4
            , modelNumber           = x5
            , specificModel         = x6
            , manufSerialNumber     = x7
            , weight                = x8
            , impellerType          = x9
            , insulationClass       = x10
            , ipRating              = x11
            , installedDesignHeadM  = x12
            , inletSizeMM           = x13
            , outletSizeMM          = x14
            , ratedSpeedRPM         = x15
            , flowLS                = x16
            , dateOfInstallation    = x17
            , locationOnSite        = x18
            , locationInHierarchy   = x19
            , memoLine              = x20
            })
        <&> getTrimmedContentNamed("Description")
        <*> getTrimmedContentNamed("Class Name")
        <*> getTrimmedContentNamed("Tag")
        <*> getTrimmedContentNamed("Manufacturer")
        <*> getTrimmedContentNamed("Model Number")
        <*> getTrimmedContentNamed("Specific Model")
        <*> getTrimmedContentNamed("Manufacturer's serial number")
        <*> optional(getFloat64Named("Weight"))
        <*> getTrimmedContentNamed("Impeller type")
        <*> getTrimmedContentNamed("Insulation Class (\u00B0c)")
        <*> getTrimmedContentNamed("IP Rating")
        <*> optional(getFloat64Named("Installed Design Head (m)"))
        <*> optional(getInt32Named("Inlet Size (mm)"))
        <*> optional(getInt32Named("Outlet Size (mm)"))
        <*> optional(getInt32Named("Rated Speed (RPM)"))
        <*> optional(getFloat64Named("Flow (l/s)"))
        <*> optional(getLocalDateNamed("Date of installation"))
        <*> getTrimmedContentNamed("Location on Site")
        <*> getTrimmedContentNamed("Location in Asset Hierarchy")
        <*> getTrimmedContentNamed("Memo Line")
        


    pub def pumpClassification(x: String): ObjectClassification = match String.toUpperCase(x) { 
        case "CENTRIFUGAL"                      => { category = "M", objectType = "PUMP", classType = "PUMPCE"}
        case s if s `String.startsWith` "RAM"   => { category = "M", objectType = "PUMP", classType = "PUMPRA"}
        case _                                  => { category = "M", objectType = "PUMP", classType = "PUMPMISC"}
    }


    pub def genPumps(xs: List[PumpRow]): GenEquiMonad[Unit] = 
        use AssetLib/GenS4/GenEquiMonad.{flatMap, return, mapM};
        use AssetLib/GenS4/GenEquiMonad.{>>=};
        let* pairs  = mapM(x1 -> genPump(x1) >>= a1 -> return((a1, x1)), xs);
        let* _      = genPumpAibReference(pairs);
        let* _      = genPumpAssetCondition(pairs);
        return()

    def genPump(x: PumpRow): GenEquiMonad[EquiRef] = 
        AssetLib/GenS4/GenEquiMonad.genEqui((x1, x2) -> pumpToSLEquipment({equiId = x1, today = x2}, x))

    /// Translation
    pub def pumpToSLEquipment(params: {equiId: String, today: Time.LocalDate}, x: PumpRow): SLEquipment = 
        let i32None: Option[Int32] = None;
        let classification = pumpClassification(x.className);
        let defaultDate = Time/LocalDate.new({dayOfMonth = 1, month = 1, year = 1970});
        { equiId                = params.equiId
        , category              = classification.category
        , description           = x.description
        , validFrom             = params.today
        , objectType            = classification.objectType
        , weightKg              = x.weight
        , startupDate           = Option.getWithDefault(x.dateOfInstallation, defaultDate)
        , manufacturer          = x.manufacturer
        , model                 = x.modelNumber
        , partNumber            = x.specificModel
        , serialNumber          = x.manufSerialNumber
        , functionalLocation    = x.locationInHierarchy
        , superOrdinateEqui     = ""
        , position              = i32None
        , techIdentNo           = x.pandiTag
        , status                = "OPER"
        }





    /// ## Aib Reference

    /// Set-oriented (should generate all facts in one go)
    pub def genPumpAibReference(xs: List[(EquiRef, PumpRow)]): GenEquiMonad[Unit] =
        use AssetLib/GenS4/Rules/Characteristics/AibReference.{equiAibReference};
        AssetLib/GenS4/GenEquiMonad.equiCharacteristicsSkeleton(pumpAibReferenceFacts,equiAibReference, xs)


    def pumpAibReferenceFacts(x: EquiRef, 
                                    pump: PumpRow): #{EquiWorkItem3 | r} = 
        AssetLib/GenS4/GenEquiMonad.withEquiRef(x, x1 -> 
            let classification      = pumpClassification(pump.className);
            #{ 
                EquiWorkItem3(x1, classification.objectType, classification.classType). 
            })



    /// ## Asset Condition

    /// Set-oriented (should generate all facts in one go)
    pub def genPumpAssetCondition(xs: List[(EquiRef, PumpRow)]): GenEquiMonad[Unit] =
        use AssetLib/GenS4/Rules/Characteristics/AssetCondition.{assetCondition};
        AssetLib/GenS4/GenEquiMonad.equiCharacteristicsSkeleton(pumpAssetConditionFacts, assetCondition, xs)



    def pumpAssetConditionFacts(x: EquiRef, 
                                    pump: PumpRow): #{EquiWorkItem3, ConditionGrade, LoadingFactor, PerformanceGrade, SurveyYear | r} = 
        AssetLib/GenS4/GenEquiMonad.withEquiRef(x, x1 -> 
            let classification      = pumpClassification(pump.className);
            let installYear         = Option.map(Time/LocalDate.getYear, pump.dateOfInstallation) |> flip(Option.getWithDefault, 1970);
            #{ 
                EquiWorkItem3(x1, classification.objectType, classification.classType). 
                ConditionGrade(x1, "1 - Good", "New").
                LoadingFactor(x1, "1 - Significantly Under Loaded", "New").
                PerformanceGrade(x1, "1 - Availability  95%", "New").
                SurveyYear(x1, installYear).
            })

    /// # Pump (not pums)

    pub def genPumpPump(xs: List[(EquiRef, PumpRow)]): GenEquiMonad[Unit] =
        AssetLib/GenS4/GenEquiMonad.equiCharacteristicsSkeleton(pumpPumpFacts, AssetLib/GenS4/Rules/Characteristics/Pump.pump, xs)

    def pumpPumpFacts(x: EquiRef, pump: PumpRow): #{EquiWorkItem3, PumpFlow, DutyHead, 
                                                    ImpellerType | r} = 
        AssetLib/GenS4/GenEquiMonad.withEquiRef(x, x1 -> 
            let classification      = pumpClassification(pump.className);
            Relation.when(classification.objectType == "PUMP", {
                let z1 = #{ EquiWorkItem3(x1, classification.objectType, classification.classType). };
                let z2 = Relation.optional(pump.flowLS,                d -> #{ PumpFlow(x1, d, "LITRES PER SECOND"). });
                let z3 = Relation.optional(pump.installedDesignHeadM,  d -> #{ DutyHead(x1, d, "METRES"). });
                let z4 = Relation.whenNot(String.isEmpty(pump.impellerType), #{ ImpellerType(x1, pump.impellerType). });
                z1 <+> z2 <+> z3 <+> z4
            }))



}
