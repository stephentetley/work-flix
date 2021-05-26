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


namespace AssetLib/S4Lite/Internal/Renumber {

    use AssetLib/FileIO/S4/UxlFile/Datatypes.{EquipmentData, EqMultilingualText, EqClassification};

    /// 9-digit
    pub def start(): Int32 & Impure = 
        let dt = Time/LocalDateTime.now();
        let x1  = Time/LocalDateTime.getMonthValue(dt) * 1000000;
        let x2  = Time/LocalDateTime.getDayOfMonth(dt) * 10000;
        let x3  = Time/LocalDateTime.getHour(dt) * 100;
        let x4  = Time/LocalDateTime.getMinute(dt);
        200000000 + x1 + x2 + x3 + x4


    pub def renumber(xs: List[EquipmentData], 
                        ys: List[EqMultilingualText], 
                        zs: List[EqClassification]): (List[EquipmentData], List[EqMultilingualText], List[EqClassification]) & Impure = 
        let n1 = start();
        let (st, xs1)   = List.mapAccumLeft(renumberEqui, (n1, Map.empty()), xs);
        let lookups     = snd(st);
        let ys1         = List.map(renumberMlText(lookups), ys);
        let zs1         = List.map(renumberClassifications(lookups), zs);
        (xs1, ys1, zs1)

    def renumberEqui(st: (Int32, Map[String, String]), x: EquipmentData): ((Int32, Map[String, String]), EquipmentData) = 
        let (n1, lookups) = st;
        let equi0 = x.equiId;
        let equi1 = "$" + "${n1}";
        let super1 = if (String.isEmpty(x.superordEquip)) "" else Map.getWithDefault(x.superordEquip, "$BAD", lookups);
        ((n1 + 1, Map.insert(equi0, equi1, lookups)), {equiId = equi1, superordEquip = super1 | x})

    def renumberMlText(lookups: Map[String, String], x: EqMultilingualText): EqMultilingualText = 
        let equi1 = Map.getWithDefault(x.equiId, "$BAD", lookups);
        {equiId = equi1 | x}

    def renumberClassifications(lookups: Map[String, String], x: EqClassification): EqClassification = 
        let equi1 = Map.getWithDefault(x.equiId, "$BAD", lookups);
        {equiId = equi1 | x}

}
