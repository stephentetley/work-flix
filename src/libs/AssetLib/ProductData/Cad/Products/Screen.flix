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

namespace AssetLib/ProductData/Cad/Products/Screen {

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

    /// "SCRC" coarse screen
    /// "SCRF" fine screen
    
    /// Cad export currently missing: 
    /// > flowLS: Option[Float64]
    /// > screenLengthM: Option[Int32]
    /// > screenWidthM: Option[Int32]
    pub type alias ScreenRow = 
        { equipmentBody :: EquipmentCommon
        }

    pub def loadRows(src: XlsxSource): Result[List[ScreenRow], String] & Impure = 
        SheetIO/Reader.allNamedRows(evalScreenRow(), src)


    pub def evalScreenRow(): NamedRowEvaluator[ScreenRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, point, getTrimmedContentNamed, getInt32Named, optional};
        let* className      = getTrimmedContentNamed("Class Name");
        let classification  = screenClassification(className);
        let* body           = AssetLib/ProductData/Cad/EquipmentCommon.evalEquipmentCommon(classification);
        point({ equipmentBody = body
            })
        

    def screenClassification(x: String): ObjectClassification = match String.toUpperCase(x) { 
        case "BAND"                 => { category = "M", objectName = "SCRF", className = "SCRFBA"}
        case _                      => { category = "M", objectName = "SCRF", className = "SCRFMISC"}
    }


    pub def generateScreens(xs: List[ScreenRow]): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, point, mapM};
        use AssetLib/GenS4/GenMonad.{>>=};
        use AssetLib/ProductData/Cad/EquipmentCommon.{genEquipment};
        let* scrnPairs  = mapM(x1 -> genEquipment(x1.equipmentBody) >>= a1 -> point((a1, x1)), xs);
        let eqbPairs    = List.map(xy -> {let (x,y) = xy; (x, y.equipmentBody)}, scrnPairs);
        let* _          = AssetLib/ProductData/Cad/EquipmentCommon.genCommonAibReference(eqbPairs);
        let* _          = AssetLib/ProductData/Cad/EquipmentCommon.genCommonAssetCondition(eqbPairs);
        /// let* _          = genScreenScrc(scrnPairs);
        /// let* _          = genScreenScrf(scrnPairs);
        point()


    /// # Scrc / Scrf

    /// def genValveValv(xs: List[(EquiRef, ScreenRow)]): GenMonad[Unit] =
    ///     AssetLib/GenS4/GenMonad.equiCharacteristicsSkeleton(valveValvFacts, AssetLib/GenS4/Rules/Characteristics/Valv.valv, xs)

    /// def valveValvFacts(x: EquiRef, valve: ScreenRow): #{EquiWorkItem3, ValveSize | r} = 
    ///     AssetLib/GenS4/GenMonad.withEquiRef(x, x1 -> 
    ///         RelLib/Relation.when(valve.equipmentBody.objectName == "VALV", {
    ///             let z1 = #{ EquiWorkItem3(x1, valve.equipmentBody.objectName, valve.equipmentBody.className). };
    ///             let z2 = RelLib/Relation.optional(valve.sizeMM,                i -> #{ ValveSize(x1, Int32.toFloat64(i), "MILLIMETRES"). });
    ///             z1 <+> z2
    ///         }))

}
