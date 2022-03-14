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


namespace S4Loader/PDT/Rules/EquiCommon {

    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int};

    use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, DateProperty, PropertyAlias, EquiObjectClass};
    use S4Loader/PDT/Gen/WorkList.{EquiWorkItem};



    pub type alias EquiCommonSchema[r1: SchemaRow] = 
        #{EquiWorkItem, EquiObjectClass, StringProperty, IntProperty, DateProperty, EquiCharacteristic | r1}


    pub def equiCommon(): EquiCommonSchema[r1] =  
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        #{

            // # AIB_REFERENCE

            /// S4_AIB_REFERENCE (blank)
            EquiCharacteristic(uid, "AIB_REFERENCE", "S4_AIB_REFERENCE", S4String("")) :-
                EquiWorkItem(uid, _).

            // # EAST_NORTH
            EquiCharacteristic(uid, "EAST_NORTH", "EASTING", S4Int(eastingfromOsgb36(ngr))) :- 
                EquiWorkItem(uid, _),
                StringProperty(uid, "@GRID_REF", ngr).

            EquiCharacteristic(uid, "EAST_NORTH", "NORTHING", S4Int(northingfromOsgb36(ngr))) :- 
                EquiWorkItem(uid, _),
                StringProperty(uid, "@GRID_REF", ngr).

            // # ASSET_CONDITION
            EquiCharacteristic(uid, "ASSET_CONDITION", "CONDITION_GRADE", S4String("1 - GOOD")) :- 
                EquiWorkItem(uid, _),
                StringProperty(uid, "@ASSET_CONDITION", "New").

            EquiCharacteristic(uid, "ASSET_CONDITION", "CONDITION_GRADE_REASON", S4String("NEW")) :- 
                EquiWorkItem(uid, _),
                StringProperty(uid, "@ASSET_CONDITION", "New").
            
            EquiCharacteristic(uid, "ASSET_CONDITION", "LOADING_FACTOR", S4String("3 - SATISFACTORY")) :- 
                EquiWorkItem(uid, _),
                StringProperty(uid, "@ASSET_CONDITION", "New").

            EquiCharacteristic(uid, "ASSET_CONDITION", "LOADING_FACTOR_REASON", S4String("NEW")) :- 
                EquiWorkItem(uid, _),
                StringProperty(uid, "@ASSET_CONDITION", "New").

            EquiCharacteristic(uid, "ASSET_CONDITION", "PERFORMANCE_GRADE", S4String("1 - AVAILABILITY 95%")) :- 
                EquiWorkItem(uid, _),
                StringProperty(uid, "@ASSET_CONDITION", "New").

            EquiCharacteristic(uid, "ASSET_CONDITION", "PERFORMANCE_GRADE_REASON", S4String("NEW")) :- 
                EquiWorkItem(uid, _),
                StringProperty(uid, "@ASSET_CONDITION", "New").

            EquiCharacteristic(uid, "ASSET_CONDITION", "SURVEY_DATE", S4Int(Time/LocalDate.getYear(localdate))) :- 
                EquiWorkItem(uid, _),
                StringProperty(uid, "@ASSET_CONDITION", "New"),
                DateProperty(uid, "Date of installation", localdate).


            // # __CLASS__

            EquiCharacteristic(uid, equiClass, "UNICLASS_CODE", S4String("")) :- 
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, _, equiClass).

            EquiCharacteristic(uid, equiClass, "UNICLASS_DESC", S4String("")) :-
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, _, equiClass).

                    
            EquiCharacteristic(uid, "SOLUTION_ID", "SOLUTION_ID", S4String(value)) :-
                EquiWorkItem(uid, _),
                StringProperty(uid, "@SOLUTION_ID", value).

            EquiCharacteristic(uid, equiClass, "LOCATION_ON_SITE", S4String(value)) :-
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, _, equiClass),
                StringProperty(uid, "Location on Site", value),
                if String.length(value) < 30.

            EquiCharacteristic(uid, equiClass, "LOCATION_ON_SITE", S4String("SEE LONG TEXT")) :-
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, _, equiClass),
                StringProperty(uid, "Location on Site", value),
                if String.length(value) >= 30.

            EquiCharacteristic(uid, equiClass, "MEMO_LINE", S4String(value)) :-
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, _, equiClass),
                StringProperty(uid, "Memo Line", value),
                if String.length(value) < 30.

            EquiCharacteristic(uid, equiClass, "MEMO_LINE", S4String("SEE LONG TEXT")) :-
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, _, equiClass),
                StringProperty(uid, "Memo Line", value),
                if String.length(value) >= 30.


        }
        


}
