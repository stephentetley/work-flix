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

namespace AutoLifting/Phase2/RenameValues {
    
 
    use AutoLifting/Datatypes.{EquiAttributes, S4CharAttributes};
    use AutoLifting.ReportMonad;


    pub def renameForS4(xs: List[{equiAttributes: EquiAttributes, charAttributes: S4CharAttributes | r}]): ReportMonad[List[{equiAttributes: EquiAttributes, charAttributes: S4CharAttributes | r}]] = 
        AutoLifting/ReportMonad.mapM(renameForS4Item, xs)

    pub def renameForS4Item[r](x: {equiAttributes: EquiAttributes, charAttributes: S4CharAttributes | r}): ReportMonad[{equiAttributes: EquiAttributes, charAttributes: S4CharAttributes | r}] = 
        use AutoLifting/ReportMonad.{flatMap, return};
        let step = renameManufacturer >> renameModel >> renameSerialNumber >> renameWorkLoadUnit;
        return(step(x))
        
    def renameManufacturer[r](x: {equiAttributes: EquiAttributes | r}): {equiAttributes: EquiAttributes | r} = 
        match x.equiAttributes.manufacturer { 
            case "UNKNOWN MANUFACTURER" => { 
                let attrs1 = {manufacturer = "TO BE DETERMINED" | x.equiAttributes};
                {equiAttributes = attrs1 | x}
            }
            case _  => x
        }

    def renameModel[r](x: {equiAttributes: EquiAttributes | r}): {equiAttributes: EquiAttributes | r} = 
        match x.equiAttributes.model { 
            case "UNSPECIFIED" => { 
                let attrs1 = {model = "TO BE DETERMINED" | x.equiAttributes};
                {equiAttributes = attrs1 | x}
            }
            case _  => x
        }        

    def renameSerialNumber[r](x: {equiAttributes: EquiAttributes | r}): {equiAttributes: EquiAttributes | r} = 
        match x.equiAttributes.serialNumber { 
            case "" => { 
                let attrs1 = {serialNumber = "UNKNOWN" | x.equiAttributes};
                {equiAttributes = attrs1 | x}
            }
            case _  => x
        } 


    def renameWorkLoadUnit[r](x: {charAttributes: S4CharAttributes | r}): {charAttributes: S4CharAttributes | r} = 
        let update = match x.charAttributes.workLoadUnits { 
            case "KILOGRAM"         => {workLoadUnits = "KG" | x.charAttributes}
            case "HUNDREDWEIGHT"    => {workLoadUnits = "CWT" | x.charAttributes}
            case "TONNE"            => {workLoadUnits = "TON (UK)" | x.charAttributes}
            case _                  => x.charAttributes
        };
        {charAttributes = update | x}


}