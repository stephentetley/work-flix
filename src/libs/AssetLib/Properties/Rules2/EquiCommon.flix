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


namespace AssetLib/Properties/Rules2/EquiCommon {

    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int};
    use AssetLib/Properties/Relations.{StringProperty, IntProperty, FloatProperty};
    use AssetLib/Properties/Rules2/CommonRelations.{EquiWorkItem3};



    pub type alias EquiCommonSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, StringProperty, IntProperty, EquiCharacteristic | r1}


    pub def equiCommon(): EquiCommonSchema[r1] =  
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        #{

            // # ASSET CONDITION

            EquiCharacteristic(equiId, "ASSET_CONDITION", "CONDITION_GRADE", 1, S4String(String.toUpperCase(grade))) :- 
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "CONDITION GRADE", grade).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "CONDITION_GRADE_REASON", 1, S4String(String.toUpperCase(reason))) :- 
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "CONDITION GRADE REASON", reason).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "LOADING_FACTOR", 1, S4String(String.toUpperCase(factor))) :-
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "LOADING FACTOR", factor).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "LOADING_FACTOR_REASON", 1, S4String(String.toUpperCase(reason))) :-
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "LOADING FACTOR REASON", reason).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "PERFORMANCE_GRADE", 1, S4String(String.toUpperCase(grade))) :-
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "PERFORMANCE GRADE", grade).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "PERFORMANCE_GRADE_REASON", 1, S4String(String.toUpperCase(reason))) :-
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "PERFORMANCE GRADE REASON", reason).

        

            // "AGASP SURVEY YEAR" => "SURVEY DATE"
            EquiCharacteristic(equiId, "ASSET_CONDITION", "SURVEY_DATE", 1, S4Int(year)) :- 
                EquiWorkItem3(equiId, _, _),
                IntProperty(equiId, "AGASP SURVEY YEAR", year).


            // # EAST_NORTH

            EquiCharacteristic(equiId, "EAST_NORTH", "EASTING", 1, S4Int(eastingfromOsgb36(ngr))) :- 
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "LOC.REF.", ngr).

            EquiCharacteristic(equiId, "EAST_NORTH", "NORTHING", 1, S4Int(northingfromOsgb36(ngr))) :- 
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "LOC.REF.", ngr).

            // # SOLUTION_ID

            EquiCharacteristic(equiId, "SOLUTION_ID", "SOLUTION_ID", 1, S4String(solutionId)) :-  
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "SOLUTION_ID", solutionId).

        }
        


}
