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


namespace AssetLib/GenS4/UploadRelations {

    
    pub rel ClassEqui(equiId: String,
                        className: String,
                        classType: String)      /// Always "002"?

    pub rel ValuaEquiText(equiId: String,
                        classType: String,
                        characteristicId: String, 
                        stringValue: String,
                        intCounterValue: Int32)

    pub rel ValuaEquiInt(equiId: String,
                        classType: String,
                        characteristicId: String, 
                        intValue: Int32,
                        intCounterValue: Int32)

    pub rel ValuaEquiFloat(equiId: String,
                        classType: String,
                        characteristicId: String, 
                        floatValue: Float64,
                        intCounterValue: Int32)

}
