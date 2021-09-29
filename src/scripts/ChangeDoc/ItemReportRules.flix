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


namespace ChangeDoc/ItemReportRules {
    

    use ChangeDoc/Relations.{Funcloc, FlocLongText, ClassFloc, ValuaFloc,
            Equipment, EquiLongText, ClassEqui, ValuaEqui, Attribute,
            FlocWorkItem, EquiWorkItem, 
            FunclocChange, FlocLongTextChange, FlocClassChange, FlocCharChange,
            EquipmentChange, EquiLongTextChange, EquiClassChange, EquiCharChange};


    pub rel HasFlocClassName(itemId: String, className: String)
    pub rel GetFlocClassName(itemId: String, charName: String, className: String)

    pub rel HasEquiClassName(itemId: String, className: String)
    pub rel GetEquiClassName(itemId: String, charName: String, className: String)


    pub def rules(): #{Funcloc, FlocLongText, ClassFloc, ValuaFloc, 
                        Equipment, EquiLongText, ClassEqui, ValuaEqui, Attribute,
                        FlocWorkItem, EquiWorkItem,
                        FunclocChange, FlocLongTextChange, FlocClassChange, FlocCharChange, 
                        EquipmentChange, EquiLongTextChange, EquiClassChange, EquiCharChange, 
                        HasFlocClassName, GetFlocClassName, HasEquiClassName, GetEquiClassName | r} = #{


        /// Floc or Equipment are 1-to-1 with their respective tab exports rather than relational.

        Funcloc(internalId, funcloc, descr) :-
            FlocWorkItem(internalId, funcloc, descr).

        /// Don't gen an attribute for deleted...
        Attribute(itemId, attrName, value) :- 
            FunclocChange(itemId, attrName, change, value),
            if change == "Changed" or change == "New".

        

        FlocLongText(itemId, language, attrName, value) :- 
            FlocWorkItem(itemId, _, _),
            FlocLongTextChange(itemId, language, attrName, change, value),
            if change == "Changed" or change == "New".


        /// Can have an equipment change without NameChange()
        Equipment(equiId, description) :- 
            EquiWorkItem(equiId, description, _).

        /// Don't gen an attribute for deleted...
        Attribute(itemId, attrName, value) :- 
            EquipmentChange(itemId, attrName, change, value),
            if change == "Changed" or change == "New".

        
        EquiLongText(itemId, language, attrName, value) :- 
            EquiWorkItem(itemId, _, _),
            EquiLongTextChange(itemId, language, attrName, change, value),
            if change == "Changed" or change == "New".



        ClassFloc(itemId, funcloc, flocName, className, change) :- 
            FlocWorkItem(itemId, funcloc, flocName),
            FlocClassChange(itemId, className, _, "Status", change, _).
            
        ClassEqui(itemId, description, className, change) :- 
            EquiWorkItem(itemId, description, _),
            EquiClassChange(itemId, className, _, "Status", change, _).
            
        /// TODO, For values, need Attribute = "Instance counter"
        /// Then test whether has "Value from" (Numeric), "Characteristic Value" (String) or neither (empty)...

        ValuaFloc(itemId, funcloc, flocName, className, charName, intCounter, change, value) :-
            FlocWorkItem(itemId, funcloc, flocName),
            GetFlocClassName(itemId, charName, className),
            FlocCharChange(itemId, charName, _, intCounter, "Value from", change, value).

        ValuaFloc(itemId, funcloc, flocName, className, charName, intCounter, change, value) :-
            FlocWorkItem(itemId, funcloc, flocName),
            GetFlocClassName(itemId, charName, className),
            FlocCharChange(itemId, charName, _, intCounter, "Characteristic Value", change, value).


        /// TODO, For values, need Attribute = "Instance counter"
        /// Then test whether has "Value from" (Numeric), "Characteristic Value" (String) or neither (empty)...

        ValuaEqui(itemId, description, className, charName, intCounter, change, value) :-
            EquiWorkItem(itemId, description, _),
            GetEquiClassName(itemId, charName, className),
            EquiCharChange(itemId, charName, _, intCounter, "Value from", change, value).

        ValuaEqui(itemId, description, className, charName, intCounter, change, value) :-
            EquiWorkItem(itemId, description, _),
            GetEquiClassName(itemId, charName, className),
            EquiCharChange(itemId, charName, _, intCounter, "Characteristic Value", change, value).


        /// We won't know the class name if it wasn't created or changed...
        HasFlocClassName(itemId, charName) :-
            FlocClassChange(itemId, className, _, _, _, _),
            S4FlocClassMember(className, charName).
        
        GetFlocClassName(itemId, charName, className) :- 
            FlocClassChange(itemId, className, _, _, _, _),
            S4FlocClassMember(className, charName).

        GetFlocClassName(itemId, charName, "[Unknown/Orphan]") :- 
            FlocCharChange(itemId, charName, _, _, _, _, _),
            not HasFlocClassName(itemId, charName).



        HasEquiClassName(itemId, charName) :-
            EquiClassChange(itemId, className, _, _, _, _),
            S4EquiClassMember(className, charName).
        
        GetEquiClassName(itemId, charName, className) :- 
            EquiClassChange(itemId, className, _, _, _, _),
            S4EquiClassMember(className, charName).

        GetEquiClassName(itemId, charName, "[Unknown/Orphan]") :- 
            EquiCharChange(itemId, charName, _, _, _, _, _),
            not HasEquiClassName(itemId, charName).


    }



}
