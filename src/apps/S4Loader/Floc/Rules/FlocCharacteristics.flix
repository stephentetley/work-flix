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


namespace S4Loader/Floc/Ruls/FlocCharacteristics {

    use RelLib.Writer;

    use AssetLib/S4Lite/Datatypes.{SLFlocCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int};
    
    use S4Loader/Base/Schema.{StringProperty, IntProperty};
    use S4Loader/Floc/WorkList.{FlocWorkItem, FlocWorkItemRow};
    
    
    pub type alias FlocCharacteristicSchema[r1: SchemaRow] = 
        #{FlocWorkItem, StringProperty, IntProperty, FlocCharacteristic | r1}


    // NOTE - there is no real need to generate these with Datalog.
    // No properties are read from the database, they are entirely derived from 
    // a single row in the worklist file.
    //
    // The only advantage of Datalog is we have much the machinary already written.
    //


    pub def flocCharacteristics(): FlocCharacteristicSchema[r1] =  
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        #{

            // # AIB_REFERENCE

            /// S4_AIB_REFERENCE (blank)
            FlocCharacteristic(funcloc, "AIB_REFERENCE", "S4_AIB_REFERENCE", S4String("")) :-
                FlocWorkItem(funcloc, _).

            /// AIB_REFERENCE (from worklist semi sep list)
            FlocCharacteristic(funcloc, "AIB_REFERENCE", "AI2_AIB_REFERENCE", S4String(sainum)) :- 
                FlocWorkItem(funcloc, _), 
                StringProperty(funcloc, "@AIB_REFERENCE", sainum).


            // # __CLASS__
            
            FlocCharacteristic(funcloc, className, "SYSTEM_TYPE", S4String(systemName)) :- 
                FlocWorkItem(funcloc, level),
                StringProperty(funcloc, "@CLASS_NAME", className),
                StringProperty(funcloc, "@SYSTEM_DESCR", systemName),
                if level == 5.
            

            // # EAST_NORTH
            FlocCharacteristic(funcloc, "EAST_NORTH", "EASTING", S4Int(eastingfromOsgb36(ngr))) :- 
                FlocWorkItem(funcloc, _),
                StringProperty(funcloc, "@GRID_REF", ngr).

            FlocCharacteristic(funcloc, "EAST_NORTH", "NORTHING", S4Int(northingfromOsgb36(ngr))) :- 
                FlocWorkItem(funcloc, _),
                StringProperty(funcloc, "@GRID_REF", ngr).

            // # SOLUTION_ID
            FlocCharacteristic(funcloc, "SOLUTION_ID", "SOLUTION_ID", S4String(solutionId)) :-  
                FlocWorkItem(funcloc, _),
                StringProperty(funcloc, "@SOLUTION_ID", solutionId).

            // # UNICLASS_CODE

            FlocCharacteristic(funcloc, "UNICLASS_CODE", "UNICLASS_CODE", S4String("")) :- 
                FlocWorkItem(funcloc, level),
                if level != 5.

            FlocCharacteristic(funcloc, "UNICLASS_CODE", "UNICLASS_DESC", S4String("")) :- 
                FlocWorkItem(funcloc, level),
                if level != 5.

        }


    pub def deriveProperties(xs: List[FlocWorkItemRow]): #{StringProperty, IntProperty | r} = 
        RelLib/Writer.execWriter(Foldable.foreachM(tellProperties, xs)) as & Pure

    def tellProperties(x: FlocWorkItemRow): Writer[ka, #(StringProperty | w), Unit] = 
        use RelLib/Writer.{flatMap, point, tell, whenTrue};
        let* _      = tell(#{ StringProperty(x.funcloc, "@GRID_REF", x.gridRef). });
        let* _      = whenTrue(not String.isEmpty(x.solutionId), tell(#{ StringProperty(x.funcloc, "@SOLUTION_ID", x.solutionId). }));
        let* _      = whenTrue(not String.isEmpty(x.systemClass), tell(#{ StringProperty(x.funcloc, "@CLASS_NAME", x.systemClass). }));
        let* _      = whenTrue(not String.isEmpty(x.systemTypeDescription), tell(#{ StringProperty(x.funcloc, "@SYSTEM_DESCR", x.systemTypeDescription). }));
        let* _      = Foldable.foreachM(s1 -> tell(#{ StringProperty(x.funcloc, "@AIB_REFERENCE", s1). }), x.sainums);
        point()



}
