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

namespace AutoLifting/Phase2/Rename {
    
 
    use AutoLifting/Datatypes.{Phase2WorkItem3};
    use AutoLifting.ReportMonad;


    pub def renameForS4(xs: List[Phase2WorkItem3]): ReportMonad[List[Phase2WorkItem3]] = 
        AutoLifting/ReportMonad.mapM(renameForS4Item, xs)

    pub def renameForS4Item(x: Phase2WorkItem3): ReportMonad[Phase2WorkItem3] = 
        use AutoLifting/ReportMonad.{flatMap, return};
        let step = renameManufacturer >> renameModel >> renameSerialNumber >> renameWorkLoadUnit;
        return(step(x))
        
    def renameManufacturer(x: Phase2WorkItem3): Phase2WorkItem3 = 
        match x.manufacturer { 
            case "UNKNOWN MANUFACTURER" => { manufacturer = "TO BE DETERMINED" | x }
            case _  => x
        }

    def renameModel(x: Phase2WorkItem3): Phase2WorkItem3 = 
        match x.model { 
            case "UNSPECIFIED" => { model = "TO BE DETERMINED" | x }
            case _  => x
        }        

    def renameSerialNumber(x: Phase2WorkItem3): Phase2WorkItem3 = 
        match x.serialNumber { 
            case "" => { serialNumber = "UNKNOWN" | x }
            case _  => x
        } 


    def renameWorkLoadUnit(x: Phase2WorkItem3): Phase2WorkItem3 = 
        match x.workLoadUnits { 
            case "KILOGRAM" => { workLoadUnits = "KG" | x }
            case _  => x
        }


}