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
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, ValveSize};
    use AssetLib/GenS4.GenMonad;
    use AssetLib/GenS4/GenMonad.EquiRef;
    use AssetLib/GenS4/GenMonad.EquiRef.{EquiRef};
    use AssetLib/ProductData/Base/Classification.{ObjectClassification};
    use AssetLib/ProductData/Cad/EquipmentCommon.{EquipmentCommon};


    
    type alias HandValveRow = 
        { equipmentBody :: EquipmentCommon
        , sizeMM :: Option[Int32]
        }

    pub def loadRows(src: XlsxSource): Result[List[HandValveRow], String] & Impure = 
        SheetIO/Reader.readAllNamedRows(src, evalHandValveRow())


    def evalHandValveRow(): NamedRowEvaluator[HandValveRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, getInt32Named, optional};
        let* className      = getTrimmedContentNamed("Class Name");
        let classification  = valveClassification(className);
        let* x1             = optional(getInt32Named("Size"));
        let* body           = AssetLib/ProductData/Cad/EquipmentCommon.evalEquipmentCommon(classification);
        return({ equipmentBody  = body
            , sizeMM            = x1
            })
        

    def valveClassification(x: String): ObjectClassification = match String.toUpperCase(x) { 
        case "ANGLE BALL VALVE"                 => { category = "M", objectName = "VALV", className = "VALVBA"}
        case _                                  => { category = "M", objectName = "VALV", className = "VALVMISC"}
    }


    pub def generateHandValves(xs: List[HandValveRow]): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return, mapM};
        use AssetLib/GenS4/GenMonad.{>>=};
        use AssetLib/ProductData/Cad/EquipmentCommon.{genEquipment};
        let* valvPairs  = mapM(x1 -> genEquipment(x1.equipmentBody) >>= a1 -> return((a1, x1)), xs);
        let eqbPairs    = List.map(xy -> {let (x,y) = xy; (x, y.equipmentBody)}, valvPairs);
        let* _          = AssetLib/ProductData/Cad/EquipmentCommon.genCommonAibReference(eqbPairs);
        let* _          = AssetLib/ProductData/Cad/EquipmentCommon.genCommonAssetCondition(eqbPairs);
        let* _          = genValveValv(valvPairs);
        return()


    /// # Valv

    def genValveValv(xs: List[(EquiRef, HandValveRow)]): GenMonad[Unit] =
        AssetLib/GenS4/GenMonad.equiCharacteristicsSkeleton(valveValvFacts, AssetLib/GenS4/Rules/Characteristics/Valv.valv, xs)

    def valveValvFacts(x: EquiRef, valve: HandValveRow): #{EquiWorkItem3, ValveSize | r} = 
        let EquiRef(x1) = x;
        RelLib/Relation.when(valve.equipmentBody.objectName == "VALV", {
            let z1 = #{ EquiWorkItem3(x1, valve.equipmentBody.objectName, valve.equipmentBody.className). };
            let z2 = RelLib/Relation.optional(valve.sizeMM,                i -> #{ ValveSize(x1, Int32.toFloat64(i), "MILLIMETRES"). });
            z1 <+> z2
        })

}
