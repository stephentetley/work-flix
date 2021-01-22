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

namespace NewLiftingItems/MakeReport/BuildItems/RewriteValues {
    
    use NewLiftingItems/Base/Datatypes.{LiftingEquipment, LiftingAttributes, LiftingClassifications};

    pub def renameForS4(x: LiftingEquipment): LiftingEquipment = 
        let rewriteA = renameManufacturer >> renameModel >> renameSerialNumber >> renameStatus;
        let rewriteC = renameWorkingLoadUnits;
        {attributes = rewriteA(x.attributes), classifications = rewriteC(x.classifications) | x}

    def renameManufacturer(x: LiftingAttributes): LiftingAttributes = 
        match x.manufacturer { 
            case "UNKNOWN MANUFACTURER" => {manufacturer = "TO BE DETERMINED" | x}
            case _  => x
        }

    def renameModel(x: LiftingAttributes): LiftingAttributes = 
        match x.model { 
            case "UNSPECIFIED" => {model = "TO BE DETERMINED" | x}
            case _  => x
        }        

    def renameSerialNumber(x: LiftingAttributes): LiftingAttributes = 
        match x.serialNumber { 
            case "" => {serialNumber = "UNKNOWN" | x}
            case _  => x
        } 

    def renameStatus(x: LiftingAttributes): LiftingAttributes = 
        match String.toUpperCase(x.status) { 
            case "DISPOSED OF" => {status = "DISP" | x}
            case "NON OPERATIONAL" => {status = "NOP" | x}
            case "OPERATIONAL" => {status = "OPER" | x}
            case _  => x
        }


    def renameWorkingLoadUnits(x: LiftingClassifications): LiftingClassifications = 
        match x.workingLoadUnits { 
            case "KILOGRAM"         => {workingLoadUnits = "KG" | x}
            case "HUNDREDWEIGHT"    => {workingLoadUnits = "CWT" | x}
            case "TONNE"            => {workingLoadUnits = "TON (UK)" | x}
            case _                  => x
        }


}