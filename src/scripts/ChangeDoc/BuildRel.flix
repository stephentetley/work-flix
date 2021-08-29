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

    pub rel HasFlocNameMap(internalFuncloc: String)

    pub def rules(): #{Funcloc, Equipment, EquiLongText, ObjectType, Attribute, 
                        ClassFloc, ClassEqui, ValuaFloc, ValuaEqui,
                        NameChange, AttrChange, ClassChange, ValuaChange, 
                        HasFlocNameMap | r} = #{

        HasFlocNameMap(itemId):- 
            FlocNameMap(itemId, _).

        Funcloc(itemId, floc, descr) :-
            NameChange("Floc", itemId, descr),
            FlocNameMap(itemId, floc).

        Funcloc(itemId, "TODO", descr) :-
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

        ClassEqui(itemId, className) :- 
            ClassChange("Equi", itemId, className).

        ClassFloc(itemId, className) :- 
            ClassChange("Floc", itemId, className).

        ValuaFloc(itemId, name, intCounter, value) :-
            ValuaChange("Floc", itemId, name, intCounter, value).

        ValuaEqui(itemId, name, intCounter, value) :-
            ValuaChange("Equi", itemId, name, intCounter, value).

    }

    pub rel ClassName(itemId: String, className: String)

    pub def query1(): #{ClassChange, ObjectType, ClassName | r} = #{
     
        ClassName(itemId, className) :- 
            ClassChange(_, itemId, className), 
            ObjectType(itemId, objName),
            if className `String.startsWith` objName.
    }


}
