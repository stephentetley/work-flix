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


/// Renumber with fresh "$Dollar" numbers

namespace AssetLib/S4Lite/Internal/FreshRenumber {

    use AssetLib/S4Lite/Datatypes.{UxlOutput, SLEquipment, SLEquiLongText, SLEquiCharacteristic};

    
    /// We must sort src.equipment so that subordinate equipment is numbered after the respective parent...
    pub def equiRenumber(src: UxlOutput): UxlOutput & Impure = 
        let n1 = AssetLib/S4Lite/Utils.getStartUid();
        let (st, equis) = Chain.mapAccumLeft(renumberEqui, (n1, Map.empty()), Chain.sortWith(compareEqui, src.equipment));
        let lookups     = snd(st);
        let texts       = Chain.map(renumberLongText(lookups), src.equiLongTexts);
        let chars       = Chain.map(renumberCharacteristic(lookups), src.equiCharacteristics);
        {equipment = equis, equiLongTexts = texts, equiCharacteristics = chars | src}

    def compareEqui(x: SLEquipment, y: SLEquipment): Comparison = 
        use Order.thenCompare;
        (x.functionalLocation <=> y.functionalLocation) `thenCompare`
            lazy (x.superOrdinateEqui <=> y.superOrdinateEqui) `thenCompare`
            lazy (x.position <=> y.position)


    def renumberEqui(st: (Int32, Map[String, String]), x: SLEquipment): ((Int32, Map[String, String]), SLEquipment) = 
        let (n1, lookups) = st;
        let equi0 = x.equiId;
        let equi1 = "$" + "${n1}";
        let super1 = if (String.isEmpty(x.superOrdinateEqui)) "" else Map.getWithDefault(x.superOrdinateEqui, "$BAD", lookups);
        ((n1 + 1, Map.insert(equi0, equi1, lookups)), {equiId = equi1, superOrdinateEqui = super1 | x})

    def renumberLongText(lookups: Map[String, String], x: SLEquiLongText): SLEquiLongText = 
        let equi1 = Map.getWithDefault(x.equiId, "$BAD", lookups);
        {equiId = equi1 | x}

    def renumberCharacteristic(lookups: Map[String, String], x: SLEquiCharacteristic): SLEquiCharacteristic = 
        let equi1 = Map.getWithDefault(x.equiId, "$BAD", lookups);
        {equiId = equi1 | x}

}
