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


namespace AssetLib/Properties/Rules2/FlocCharacteristics {

    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int};
    use AssetLib/Properties/Relations.{StringProperty, IntProperty};
    use AssetLib/Properties/Rules2/CommonRelations.{FlocWorkItem3};



    pub type alias FlocCharacteristicSchema[r1: SchemaRow] = 
        #{FlocWorkItem3, StringProperty, IntProperty, FlocCharacteristic | r1}


    pub def flocCharacteristics(): FlocCharacteristicSchema[r1] =  
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        #{

            // # AIB_REFERENCE

            /// S4_AIB_REFERENCE (blank)
            FlocCharacteristic(floc, "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
                FlocWorkItem3(floc, _, _).

            /// AIB_REFERENCE (from worklist semi sep list)
            FlocCharacteristic(floc, "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(sainum)) :- 
                FlocWorkItem3(floc, _, _), 
                StringProperty(floc, "@AIB_REFERENCE", sainum).


            // # __CLASS__
            
            FlocCharacteristic(funcloc, className, "SYSTEM_TYPE", 1, S4String(systemName)) :- 
                FlocWorkItem3(funcloc, level, _),
                StringProperty(floc, "@CLASS_NAME", className),
                StringProperty(floc, "@SYSTEM_TYPE", systemName),
                if level == 5.
            


            // # EAST_NORTH
            // (NGR is mandatory so could be added to FlocWorkItem)
            FlocCharacteristic(floc, "EAST_NORTH", "EASTING", 1, S4Int(eastingfromOsgb36(ngr))) :- 
                FlocWorkItem3(floc, _, ngr).

            FlocCharacteristic(floc, "EAST_NORTH", "NORTHING", 1, S4Int(northingfromOsgb36(ngr))) :- 
                FlocWorkItem3(floc, _, ngr).

            // # SOLUTION_ID

            FlocCharacteristic(floc, "SOLUTION_ID", "SOLUTION_ID", 1, S4String(solutionId)) :-  
                FlocWorkItem3(floc, _, _),
                StringProperty(floc, "@SOLUTION_ID", solutionId).

            // # UNICLASS_CODE

            FlocCharacteristic(funcloc, "UNICLASS_CODE", "UNICLASS_CODE", 1, S4String("")) :- 
                FlocWorkItem3(funcloc, level, _),
                if level != 5.

            FlocCharacteristic(funcloc, "UNICLASS_CODE", "UNICLASS_DESC", 1, S4String("")) :- 
                FlocWorkItem3(funcloc, level, _),
                if level != 5.

        }
        


}
