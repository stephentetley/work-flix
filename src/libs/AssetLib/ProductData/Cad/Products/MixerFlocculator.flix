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

namespace AssetLib/ProductData/Cad/Products/MixerFlocculator {

    use SheetIO.NamedRowEvaluator;
    use SheetIO/Reader.XlsxSource;

    use AssetLib/S4Lite/Datatypes.{UxlSource, SLEquipment, SLEquiCharacteristic, SLDatatype};
    use AssetLib/S4Lite/Datatypes.SLDatatype.{Character, NumericInt, NumericFloat};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, ValveSize};
    use AssetLib/GenS4.GenEquiMonad;
    use AssetLib/GenS4/GenEquiMonad.EquiRef;
    use AssetLib/GenS4/GenEquiMonad.EquiRef.{EquiRef};
    use AssetLib/ProductData/Base/Classification.{ObjectClassification};
    use AssetLib/ProductData/Cad/EquipmentCommon.{EquipmentCommon};

    /// "MIXR" 
    
    
    /// Cad export currently missing: 
    /// > speedRPM: Option[Int32]
    /// > ratedPowerKW: Option[Float32]
    type alias MixerFlocculatorRow = 
        { equipmentBody: EquipmentCommon
        }

    pub def loadRows(src: XlsxSource): Result[List[MixerFlocculatorRow], String] & Impure = 
        SheetIO/Reader.readAllNamedRows(src, evalMixerFlocculatorRow())


    pub def evalMixerFlocculatorRow(): NamedRowEvaluator[MixerFlocculatorRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, getInt32Named, optional};
        let* className      = getTrimmedContentNamed("Class Name");
        let classification  = mixerFlocculatorClassification(className);
        let* body           = AssetLib/ProductData/Cad/EquipmentCommon.evalEquipmentCommon(classification);
        return({ equipmentBody = body
            })
        

    def mixerFlocculatorClassification(x: String): ObjectClassification = match String.toUpperCase(x) { 
        case "BAND"                 => { category = "M", objectName = "SCRF", className = "SCRFBA"}
        case _                      => { category = "M", objectName = "SCRF", className = "SCRFMISC"}
    }


    pub def generateMixerFlocculators(xs: List[MixerFlocculatorRow]): GenEquiMonad[Unit] = 
        use AssetLib/GenS4/GenEquiMonad.{flatMap, return, mapM};
        use AssetLib/GenS4/GenEquiMonad.{>>=};
        use AssetLib/ProductData/Cad/EquipmentCommon.{genEquipment};
        let* scrnPairs  = mapM(x1 -> genEquipment(x1.equipmentBody) >>= a1 -> return((a1, x1)), xs);
        let eqbPairs    = List.map(xy -> {let (x,y) = xy; (x, y.equipmentBody)}, scrnPairs);
        let* _          = AssetLib/ProductData/Cad/EquipmentCommon.genCommonAibReference(eqbPairs);
        let* _          = AssetLib/ProductData/Cad/EquipmentCommon.genCommonAssetCondition(eqbPairs);
        /// let* _          = genScreenScrc(scrnPairs);
        /// let* _          = genScreenScrf(scrnPairs);
        return()


    /// # Scrc / Scrf

    /// def genValveValv(xs: List[(EquiRef, ScreenRow)]): GenEquiMonad[Unit] =
    ///     AssetLib/GenS4/GenEquiMonad.equiCharacteristicsSkeleton(valveValvFacts, AssetLib/GenS4/Rules/Characteristics/Valv.valv, xs)

    /// def valveValvFacts(x: EquiRef, valve: ScreenRow): #{EquiWorkItem3, ValveSize | r} = 
    ///     AssetLib/GenS4/GenEquiMonad.withEquiRef(x, x1 -> 
    ///         Relation.when(valve.equipmentBody.objectName == "VALV", {
    ///             let z1 = #{ EquiWorkItem3(x1, valve.equipmentBody.objectName, valve.equipmentBody.className). };
    ///             let z2 = Relation.optional(valve.sizeMM,                i -> #{ ValveSize(x1, Int32.toFloat64(i), "MILLIMETRES"). });
    ///             z1 <+> z2
    ///         }))

}
