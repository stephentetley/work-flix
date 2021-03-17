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


namespace DwfOverflow/Relations {

    /// Arity 5 - if Floc `funcloc` has data, `equiId` is empty; if Equi `funcloc` is empty and `equiId` has data.
    pub rel ChangeRequestItem(description: String, crType: String, funcloc: String, equiId: String, processReq: String)

    /// Arity 14
    pub rel FlocDatum(funcloc: String, maskedFuncloc: String, description: String, 
        category: Int32, strIndicator: String, objectType: String, 
        startupDate: Time.LocalDate, maintPlant: Int32, companyCode: Int32, 
        coArea: Int32, supFunctLoc: String, equipInstall: Bool, 
        statusProfile: String, userStatus: String)

    /// Arity 6
    pub rel Characteristic(floc: String, classType: String, className: String, status: Int32, charName: String, charValue: String)



}