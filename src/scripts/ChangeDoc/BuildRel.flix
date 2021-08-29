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


namespace ChangeDoc/BuildRel {
    
    use ChangeDoc/Datatypes.{EntityType};
    use ChangeDoc/Datatypes.EntityType.{Floc, Equi};
    use ChangeDoc/Relations.{Funcloc, Equipment,
        EquiLongText, ObjectType, Attribute, ClassFloc, ClassEqui, ValuaFloc, ValuaEqui,
        FlocNameMap, 
        NameChange, AttrChange, ClassChange, LongTextChange, ValuaChange};
    use AssetLib/FileIO/S4/ClassList/Relations.{S4ClassMember};

    pub rel HasFlocNameMap(internalFuncloc: String)

    pub rel ClassUsed(itemId: String, className: String)

    pub def rules(): #{Funcloc, Equipment, EquiLongText, ObjectType, Attribute, 
                        ClassFloc, ClassEqui, ValuaFloc, ValuaEqui,
                        NameChange, AttrChange, ClassChange, ValuaChange, LongTextChange, 
                        FlocNameMap, HasFlocNameMap, S4ClassMember, ClassUsed | r} = #{

        HasFlocNameMap(itemId) :- 
            FlocNameMap(itemId, _).


        Funcloc(itemId, funcloc, descr) :-
            NameChange("Floc", itemId, descr),
            FlocNameMap(itemId, funcloc).

        Funcloc(itemId, "[Unknown]", descr) :-
            NameChange("Floc", itemId, descr),
            not HasFlocNameMap(itemId).


        Equipment(itemId, name) :- 
            NameChange("Equi", itemId, name).

        EquiLongText(itemId, descr, "") :- 
            LongTextChange("Equi", itemId, "Description (medium text)", descr).

        ObjectType(itemId, value) :- 
            AttrChange(itemId, "Object Type", value).

        Attribute(itemId, name, value) :- 
            AttrChange(itemId, name, value), 
            if name != "Object Type".


        ClassFloc(itemId, funcloc, className, status) :- 
            ClassChange("Floc", itemId, className, status), 
            FlocNameMap(itemId, funcloc).
        
        ClassFloc(itemId, "[Unknown]", className, status) :- 
            ClassChange("Floc", itemId, className, status), 
            not HasFlocNameMap(itemId).

        ClassEqui(itemId, className, status) :- 
            ClassChange("Equi", itemId, className, status).

        ClassUsed(itemId, className) :- 
            ClassChange(_, itemId, className, _).
        
            
        
        ValuaFloc(itemId, funcloc, className, charName, intCounter, status, value) :-
            ValuaChange("Floc", itemId, charName, intCounter, value, status),
            FlocNameMap(itemId, funcloc), 
            ClassUsed(itemId, className),
            S4ClassMember(className, charName).

        ValuaFloc(itemId, "[Unknown]", className, charName, intCounter, status, value) :-
            ValuaChange("Floc", itemId, charName, intCounter, value, status),
            ClassUsed(itemId, className),
            S4ClassMember(className, charName),
            not HasFlocNameMap(itemId).


        ValuaEqui(itemId, className, charName, intCounter, status, value) :-
            ValuaChange("Equi", itemId, charName, intCounter, value, status), 
            ClassUsed(itemId, className),
            S4ClassMember(className, charName).

    }

    /// pub rel ClassName(itemId: String, className: String)

    /// pub def query1(): #{ClassChange, ObjectType, ClassName | r} = #{
     
    ///     ClassName(itemId, className) :- 
    ///         ClassChange(_, itemId, className), 
    ///         ObjectType(itemId, objName),
    ///         if className `String.startsWith` objName.
    /// }


}
