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

namespace AssetLib/ProductData/Cad/Products/Pump {

    use SheetIO.NamedRowEvaluator;
    use SheetIO/Reader.XlsxSource;

    use AssetLib/S4Lite/Datatypes.{UxlSource, SLEquipment, SLEquiCharacteristic, SLDatatype};
    use AssetLib/S4Lite/Datatypes.SLDatatype.{Character, NumericInt, NumericFloat};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, 
        ConditionGrade, LoadingFactor, PerformanceGrade, SurveyYear, 
        Flow, DutyHead, ImpellerType};
    use AssetLib/GenS4.GenMonad;
    use AssetLib/GenS4/GenMonad.EquiRef;
    use AssetLib/GenS4/GenMonad.EquiRef.{EquiRef};
    use AssetLib/ProductData/Base/Classification.{ObjectClassification};
    use AssetLib/ProductData/Cad/EquipmentCommon.{EquipmentCommon};

    /// Base is PUMP (category "M") / PUMS (category "E")
    /// PUMPDI | ...

    
    type alias PumpRow = 
        { equipmentBody: EquipmentCommon
        , impellerType: String
        , insulationClass: String
        , ipRating: String
        , installedDesignHeadM: Option[Float64]
        , inletSizeMM: Option[Int32]
        , outletSizeMM: Option[Int32]
        , ratedSpeedRPM: Option[Int32]
        , flowLS: Option[Float64]
        }

    pub def loadRows(src: XlsxSource): Result[List[PumpRow], String] & Impure = 
        SheetIO/Reader.readAllNamedRows(src, evalPumpRow())


    def evalPumpRow(): NamedRowEvaluator[PumpRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, 
            getInt32Named, getFloat64Named, getLocalDateNamed, optional};
        let* className      = getTrimmedContentNamed("Class Name");
        let classification  = pumpClassification(className);
        let* x1             = getTrimmedContentNamed("Impeller type");
        let* x2             = getTrimmedContentNamed("Insulation Class (\u00B0c)");
        let* x3             = getTrimmedContentNamed("IP Rating");
        let* x4             = optional(getFloat64Named("Installed Design Head (m)"));
        let* x5             = optional(getInt32Named("Inlet Size (mm)"));
        let* x6             = optional(getInt32Named("Outlet Size (mm)"));
        let* x7             = optional(getInt32Named("Rated Speed (RPM)"));
        let* x8             = optional(getFloat64Named("Flow (l/s)"));
        let* body           = AssetLib/ProductData/Cad/EquipmentCommon.evalEquipmentCommon(classification);
        return({ equipmentBody      = body
            , impellerType          = x1
            , insulationClass       = x2
            , ipRating              = x3
            , installedDesignHeadM  = x4
            , inletSizeMM           = x5
            , outletSizeMM          = x6
            , ratedSpeedRPM         = x7
            , flowLS                = x8
            })

        


    def pumpClassification(x: String): ObjectClassification = match String.toUpperCase(x) { 
        case "CENTRIFUGAL"                      => { category = "M", objectName = "PUMP", className = "PUMPCE"}
        case s if s `String.startsWith` "RAM"   => { category = "M", objectName = "PUMP", className = "PUMPRA"}
        case _                                  => { category = "M", objectName = "PUMP", className = "PUMPMISC"}
    }


    pub def generatePumps(xs: List[PumpRow]): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return, mapM};
        use AssetLib/GenS4/GenMonad.{>>=};
        use AssetLib/ProductData/Cad/EquipmentCommon.{genEquipment};
        let* pumpPairs  = mapM(x1 -> genEquipment(x1.equipmentBody) >>= a1 -> return((a1, x1)), xs);
        let eqbPairs    = List.map(xy -> {let (x,y) = xy; (x, y.equipmentBody)}, pumpPairs);
        let* _          = AssetLib/ProductData/Cad/EquipmentCommon.genCommonAibReference(eqbPairs);
        let* _          = AssetLib/ProductData/Cad/EquipmentCommon.genCommonAssetCondition(eqbPairs);
        let* _          = genPumpPump(pumpPairs);
        return()




    /// # Pump (not pums)

    def genPumpPump(xs: List[(EquiRef, PumpRow)]): GenMonad[Unit] =
        AssetLib/GenS4/GenMonad.equiCharacteristicsSkeleton(pumpPumpFacts, AssetLib/GenS4/Rules/Characteristics/Pump.pump, xs)

    def pumpPumpFacts(x: EquiRef, pump: PumpRow): #{EquiWorkItem3, Flow, DutyHead, 
                                                    ImpellerType | r} = 
        let EquiRef(x1) = x;
        Relation.when(pump.equipmentBody.objectName == "PUMP", {
            let z1 = #{ EquiWorkItem3(x1, pump.equipmentBody.objectName, pump.equipmentBody.className). };
            let z2 = Relation.optional(pump.flowLS,                d -> #{ Flow(x1, d, "LITRES PER SECOND"). });
            let z3 = Relation.optional(pump.installedDesignHeadM,  d -> #{ DutyHead(x1, d, "METRES"). });
            let z4 = Relation.whenNot(String.isEmpty(pump.impellerType), #{ ImpellerType(x1, pump.impellerType). });
            z1 <+> z2 <+> z3 <+> z4
        })


}
