/*
 * Copyright 2022 Stephen Tetley
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

namespace S4Loader/Base/Schema {

    /// ## Property relations
    
    pub type alias S4Properties[r1: SchemaRow] =
        #{StringProperty, IntProperty, FloatProperty, DateProperty | r1}


    pub rel StringProperty(uid: String, propName: String, propValue: String)

    pub rel IntProperty(uid: String, propName: String, propValue: Int32)

    pub rel FloatProperty(uid: String, propName: String, propValue: Float64)

    pub rel DateProperty(uid: String, propName: String, propValue: Time.LocalDate)


    pub rel PropertyAlias(aiPropName: String, s4Class: String, s4Chararacteristic: String)

    pub rel EquiObjectClass(uid: String , s4Object: String, s4Class : String)

    /// ## WorkList relations
    /// (This might be the wrong place for these - Aib/PDT may have different WorkItem relations)

    pub rel FlocWorkItem3(s4Floc: String, level: Int32, ngr: String)

    /// `uid` will be pli-number for facts extracted from Aib Exports.
    /// But it can represent other item types depending where the facts come from.

    pub rel EquiWorkItem3(uid: String, s4ObjType: String, s4Class: String)

    /// from Equi (002) Class List
    pub rel EquiCharacteristicSpec(className: String, charName: String, description: String, s4Type: String, textLength: Int32, decimalPlaces: Int32)
}
