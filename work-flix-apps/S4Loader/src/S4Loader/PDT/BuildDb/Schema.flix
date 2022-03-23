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

namespace S4Loader/PDT/BuildDb/Schema {

    use RelLib/Lattice/Constant.Constant;

    pub rel PDTRawValue(itemName: String, pdtAssetClass: String, fieldName: String, fieldValue: String)

    pub rel FieldType(fieldName: String, pdtType: String)

    pub rel FieldEvalSpec(fieldName: String, pdtAssetClass: String, fieldType: String, evaluatorType: String, evaluator: String, evalArg1: String)

    pub rel FieldValueEnum(fieldName: String, pdtAssetClass: String, pdtValue : String, s4Value: String)

    
    pub type alias S4Properties[r1: SchemaRow] =
        #{StringPropertyLat, IntPropertyLat, FloatPropertyLat, DatePropertyLat | r1}


    pub lat StringPropertyLat(uid: String, propName: String, propValue: Constant[String])

    pub lat IntPropertyLat(uid: String, propName: String, propValue: Constant[Int32])

    pub lat FloatPropertyLat(uid: String, propName: String, propValue: Constant[Float64])

    pub lat DatePropertyLat(uid: String, propName: String, propValue: Constant[Time.LocalDate])

    

}
