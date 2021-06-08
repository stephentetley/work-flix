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

    use AssetLib/S4Lite/Datatypes.{UxlSource, SLEquipment, SLEquiLongText, SLEquiCharacteristic};

    

    pub def equiRenmumber(src: UxlSource): UxlSource & Impure = 
        let n1 = start();
        let (st, equis) = Chain.mapAccumLeft(renumberEqui, (n1, Map.empty()), src.equipment);
        let lookups     = snd(st);
        let texts       = Chain.map(renumberLongText(lookups), src.equiLongTexts);
        let chars       = Chain.map(renumberCharacteristic(lookups), src.equiCharacteristics);
        {equipment = equis, equiLongTexts = texts, equiCharacteristics = chars | src}

    /// 9-digit
    def start(): Int32 & Impure = 
        let dt = Time/LocalDateTime.now();
        let x1  = Time/LocalDateTime.getMonthValue(dt) * 1000000;
        let x2  = Time/LocalDateTime.getDayOfMonth(dt) * 10000;
        let x3  = Time/LocalDateTime.getHour(dt) * 100;
        let x4  = Time/LocalDateTime.getMinute(dt);
        200000000 + x1 + x2 + x3 + x4

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
