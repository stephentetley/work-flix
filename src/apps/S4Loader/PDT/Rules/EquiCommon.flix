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

    use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, DateProperty};
    use S4Loader/PDT/Rules/Schema.{EquiWorkItem};



    pub type alias EquiCommonSchema[r1: SchemaRow] = 
        #{EquiWorkItem, StringProperty, IntProperty, EquiCharacteristic | r1}


    pub def equiCommon(): EquiCommonSchema[r1] =  
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        #{

            // # AIB_REFERENCE

            /// S4_AIB_REFERENCE (blank)
            EquiCharacteristic(uid, "AIB_REFERENCE", "S4_AIB_REFERENCE", S4String("")) :-
                EquiWorkItem(uid, _).

            // # __CLASS__

            EquiCharacteristic(uid, s4EquiClass, "UNICLASS_CODE", S4String("")) :- 
                EquiWorkItem(uid, _, s4EquiClass).

            EquiCharacteristic(uid, s4EquiClass, "UNICLASS_DESC", S4String("")) :-
                EquiWorkItem(uid, _, s4EquiClass).

            EquiCharacteristic(uid, s4EquiClass, "LOCATION_ON_SITE", S4String(value)) :-
                EquiWorkItem(uid, _, s4EquiClass),
                StringProperty(uid, "LOCATION ON SITE", value),
                if String.length(value) < 30.

            EquiCharacteristic(uid, s4EquiClass, "LOCATION_ON_SITE", S4String("SEE LONG TEXT")) :-
                EquiWorkItem3(uid, _, s4EquiClass),
                StringProperty(uid, "LOCATION ON SITE", value),
                if String.length(value) >= 30.


            EquiCharacteristic(uid, "SOLUTION_ID", "SOLUTION_ID", S4String(solutionId)) :-  
                EquiWorkItem(uid, _, _),
                StringProperty(uid, "@SOLUTION_ID", solutionId).

        }
        


}
