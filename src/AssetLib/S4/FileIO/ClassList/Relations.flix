/*
 * Copyright 2020 Stephen Tetley
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
    

namespace AssetLib/S4/FileIO/ClassList/Relations {

    pub enum Datatype { 
        case Text,
        case IntNum,
        case DecimalNum,
        case Date
    }

    

    rel EquiCharacteristic(classType: String, className: String, charName: String, datatype: Datatype, charLength: Int32, decimalPrec: Option[Int32])

    rel EquiRefinesChoice(classType: String, className: String, charName: String, value: String)

    rel EquiRefinesRange(classType: String, className: String, charName: String, lowest: Int32, highest: Int32)

    rel FlocCharacteristic(classType: String, className: String, charName: String, datatype: Datatype, charLength: Int32, decimalPrec: Option[Int32])

    rel FlocRefinesChoice(classType: String, className: String, charName: String, value: String)

    rel FlocRefinesRange(classType: String, className: String, charName: String, lowest: Int32, highest: Int32)

}