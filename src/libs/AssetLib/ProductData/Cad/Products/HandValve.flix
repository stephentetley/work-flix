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

namespace AssetLib/ProductData/Cad/Products/HandValve {

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
    use AssetLib/ProductData/Cad/EquipmentCommon.{EquipmentCommon};


    
    type alias HandValveRow = 
        { equiBody: EquipmentCommon
        , sizeMM: Int32
        }

    pub def loadPumpRows(src: XlsxSource): Result[List[HandValveRow], String] & Impure = 
        SheetIO/Reader.readAllNamedRows(src, evalPumpRow())


    pub def evalPumpRow(): NamedRowEvaluator[HandValveRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, getInt32Named};
        let* className      = getTrimmedContentNamed("Class Name");
        let classification  = valveClassification(className);
        let* sizeMM         = getInt32Named("Size");
        let* body           = AssetLib/ProductData/Cad/EquipmentCommon.evalEquipmentCommon(classification);
        return({equiBody = body, sizeMM = sizeMM})
        

    pub def valveClassification(x: String): ObjectClassification = match String.toUpperCase(x) { 
        case "ANGLE BALL VALVE"                 => { category = "M", objectType = "VALV", classType = "VALVBA"}
        case _                                  => { category = "M", objectType = "VALV", classType = "VALVMISC"}
    }


}
