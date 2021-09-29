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
    

    use ChangeDoc/Relations.{Funcloc, Equipment,
        EquiLongText, ObjectType, Attribute, ClassFloc, ClassEqui, ValuaFloc, ValuaEqui,
        FlocWorkItem, EquiWorkItem, 
        NameChange, AttrChange, ClassChange, LongTextChange, ValuaChange};


    pub rel HasFlocClassName(itemId: String, className: String)
    pub rel GetFlocClassName(itemId: String, charName: String, className: String)

    pub rel HasEquiClassName(itemId: String, className: String)
    pub rel GetEquiClassName(itemId: String, charName: String, className: String)


    pub def rules(): #{Funcloc, Equipment,
                        FlocWorkItem, EquiWorkItem| r} = #{


        /// Floc or Equipment are 1-to-1 with their respective tab exports rather than relational.

        Funcloc(internalId, funcloc, descr) :-
            FlocWorkItem(internalId, funcloc, descr).

        /// Can have an equipment change without NameChange()
        Equipment(equiId, description) :- 
            EquiWorkItem(equiId, description, _).



        /// /// TODO need a sample with long text to see how to replace the empty string...
        /// EquiLongText(itemId, descr, "") :- 
        ///     LongTextChange("Equi", itemId, "Description (medium text)", descr).

        /// ObjectType(itemId, value) :- 
        ///     AttrChange(_, itemId, "Object Type", value).

        /// Attribute(itemId, name, value) :- 
        ///     AttrChange(_, itemId, name, value), 
        ///     if name != "Object Type".


        /// ClassFloc(itemId, funcloc, flocName, className, status) :- 
        ///     ClassChange("Floc", itemId, className, status), 
        ///     NameChange("Floc", itemId, flocName),
        ///     FlocWorkItem(itemId, funcloc, _).
        


        /// ClassEqui(itemId, equiName, className, status) :- 
        ///     ClassChange("Equi", itemId, className, status),
        ///     NameChange("Equi", itemId, equiName).
        
        /// HasFlocClassName(itemId, charName) :-
        ///     ClassChange(_, itemId, className, _),
        ///     S4FlocClassMember(className, charName).
        
        /// GetFlocClassName(itemId, charName, className) :- 
        ///     ClassChange(_, itemId, className, _),
        ///     S4FlocClassMember(className, charName).

        /// GetFlocClassName(itemId, charName, "[Unknown/Orphan]") :- 
        ///     ValuaChange(_, itemId, charName, _, _, _),
        ///     not HasFlocClassName(itemId, charName).

        /// ValuaFloc(itemId, funcloc, flocName, className, charName, intCounter, status, value) :-
        ///     ValuaChange("Floc", itemId, charName, intCounter, value, status),
        ///     FlocWorkItem(itemId, funcloc, flocName),
        ///     GetFlocClassName(itemId, charName, className).



        /// HasEquiClassName(itemId, charName) :-
        ///     ClassChange(_, itemId, className, _),
        ///     S4EquiClassMember(className, charName).
        
        /// GetEquiClassName(itemId, charName, className) :- 
        ///     ClassChange(_, itemId, className, _),
        ///     S4EquiClassMember(className, charName).

        /// GetEquiClassName(itemId, charName, "[Unknown/Orphan]") :- 
        ///     ValuaChange(_, itemId, charName, _, _, _),
        ///     not HasEquiClassName(itemId, charName).

        /// /// Don't join on name change
        /// ValuaEqui(itemId, descr, className, charName, intCounter, status, value) :-
        ///     ValuaChange("Equi", itemId, charName, intCounter, value, status),
        ///     EquiWorkItem(itemId, descr, _), 
        ///     GetEquiClassName(itemId, charName, className).

    }



}
