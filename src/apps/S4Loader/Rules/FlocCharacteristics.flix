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


namespace S4Loader/Rules/FlocCharacteristics {

    use AssetLib/S4Lite/Datatypes.{SLFlocCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int};
    
    use S4Loader/Base/Relations.{StringProperty, IntProperty, FlocWorkItem3};
    use S4Loader/WorkLists.{FlocWorkItem};
    
    // TODO don't use relations.
    

    pub type alias FlocCharacteristicSchema[r1: SchemaRow] = 
        #{FlocWorkItem3, StringProperty, IntProperty, FlocCharacteristic | r1}


    // NOTE - there is no real need to generate these with Datalog.
    // No properties are read from the database, they are entirely derived from a row 
    // in the worklist file.



    pub def flocCharacteristics(): FlocCharacteristicSchema[r1] =  
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        #{

            // # AIB_REFERENCE

            /// S4_AIB_REFERENCE (blank)
            FlocCharacteristic(funcloc, "AIB_REFERENCE", "S4_AIB_REFERENCE", S4String("")) :-
                FlocWorkItem3(funcloc, _, _).

            /// AIB_REFERENCE (from worklist semi sep list)
            FlocCharacteristic(funcloc, "AIB_REFERENCE", "AI2_AIB_REFERENCE", S4String(sainum)) :- 
                FlocWorkItem3(funcloc, _, _), 
                StringProperty(funcloc, "@AIB_REFERENCE", sainum).


            // # __CLASS__
            
            FlocCharacteristic(funcloc, className, "SYSTEM_TYPE", S4String(systemName)) :- 
                FlocWorkItem3(funcloc, level, _),
                StringProperty(funcloc, "@CLASS_NAME", className),
                StringProperty(funcloc, "@SYSTEM_TYPE", systemName),
                if level == 5.
            


            // # EAST_NORTH
            // (NGR is mandatory so could be added to FlocWorkItem)
            FlocCharacteristic(funcloc, "EAST_NORTH", "EASTING", S4Int(eastingfromOsgb36(ngr))) :- 
                FlocWorkItem3(funcloc, _, ngr).

            FlocCharacteristic(funcloc, "EAST_NORTH", "NORTHING", S4Int(northingfromOsgb36(ngr))) :- 
                FlocWorkItem3(funcloc, _, ngr).

            // # SOLUTION_ID

            FlocCharacteristic(funcloc, "SOLUTION_ID", "SOLUTION_ID", S4String(solutionId)) :-  
                FlocWorkItem3(funcloc, _, _),
                StringProperty(funcloc, "@SOLUTION_ID", solutionId).

            // # UNICLASS_CODE

            FlocCharacteristic(funcloc, "UNICLASS_CODE", "UNICLASS_CODE", S4String("")) :- 
                FlocWorkItem3(funcloc, level, _),
                if level != 5.

            FlocCharacteristic(funcloc, "UNICLASS_CODE", "UNICLASS_DESC", S4String("")) :- 
                FlocWorkItem3(funcloc, level, _),
                if level != 5.

        }
        

    // Note - generating S4Lite without Datalog is currently cumbersome. 
    // Maybe we need a mini-DSL...

    pub def uniclassCode(r: FlocWorkItem): Chain[SLFlocCharacteristic] = 
        use AssetLib/S4Lite/Datatypes.SLDatatype.{Character};
        if (r.level != 5) 
            Chain.singleton(
                { funcloc           = r.funcloc
                , className         = "UNICLASS_CODE"
                , charName          = "UNICLASS_DESC"
                , valueType         = Character
                , charValue         = ""
                })
        else
            Chain.empty()

}
