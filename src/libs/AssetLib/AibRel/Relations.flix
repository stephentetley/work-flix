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


namespace AssetLib/AibRel/Relations {

    /// Note - not sure how general these relations are...

    pub rel AibFloc(aibref: String, commonName: String, aibSite: String, node: String, installedFrom: Time.LocalDate)

    pub rel AibEquipment(aibref: String, 
                            aibSite : String, 
                            description: String, 
                            equipmentType: String, 
                            installedFrom: Time.LocalDate, 
                            manufacturer: String, 
                            model: String, 
                            partNumber: String, 
                            serialNumber: String, 
                            gridRef: String,
                            pandiNumber: String, 
                            status: String)

    
}
