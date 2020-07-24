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


    rel ClassMember(className: String, charName: String)
    rel Characteristic(charName: String, datatype: Datatype, charLength: Int32, decimalPrec: Option[Int32])
    rel SelectionValue(charName: String, value: String)
    rel IntRange(charName: String, lowest: Int32, highest: Int32)
    rel DecimalRange(charName: String, lowest: Float64, highest: Float64)

}