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


namespace ChangeDoc/Relations {
    
    use ChangeDoc/Datatypes.{ChangeKey, ValueState, EntityType};
    use ChangeDoc/Datatypes.ChangeKey.{NameKey, ClassKey, 
        AttrKey, ValuaKey, AddrAttrKey};
    use ChangeDoc/Datatypes.EntityType.{Equi, Floc};
    use ChangeDoc/Datatypes.ValueState.{CreateLocal, DeleteLocal, 
        UpdateGlobal, DeleteGlobal};
    use ChangeDoc/Interpreter.{State};
    
    /// entity should be "Floc" or "Equi"
    pub rel NameChange(entity: String, itemId: String, name: String)

    
    pub rel AttrChange(itemId: String, name: String, value: String)
    
    pub rel ClassChange(itemId: String, className: String)

    pub rel ValuaChange(itemId: String, charName: String, intCounter: Int32, value: String)

    pub rel Funcloc(internalId: String, functionalLocation: String, description: String)

    pub rel Equipment(equiId: String, description: String)

    pub rel ObjectType(itemId: String, objType: String)

    pub rel Attribute(itemId: String, attrName: String, attrValue: String)

    pub rel Class(itemId: String, name: String)

    pub rel Characteristic(itemId: String, name: String, intCounter: Int32, value: String)

    pub def makeChangeRelations(st: State): #{NameChange, AttrChange | r} = 
        Relation.foldMap(makeChangeRelation1, Map.toList(st))

    /// To do this should make relations that include value "state".
    def makeChangeRelation1(xy: (ChangeKey, ValueState)): #{NameChange, AttrChange | r} = match xy { 
        case (NameKey(entity, itemId), CreateLocal(name)) => #{ NameChange("${entity}", itemId, name). }
        case (NameKey(entity, itemId), UpdateGlobal(name)) => #{ NameChange("${entity}", itemId, name). }

        case (ClassKey(_, itemId, className), CreateLocal("1")) => #{ ClassChange(itemId, className). }
        case (ClassKey(_, itemId, className), UpdateGlobal("1")) => #{ ClassChange(itemId, className). }

        case (AttrKey(_, itemId, name), CreateLocal(value)) => #{ AttrChange(itemId, name, value). }
        case (AttrKey(_, itemId, name), UpdateGlobal(value)) => #{ AttrChange(itemId, name, value). }

        case (ValuaKey(_, itemId, name, intCount), CreateLocal(value)) => #{ ValuaChange(itemId, name, intCount, value). }
        case (ValuaKey(_, itemId, name, intCount), UpdateGlobal(value)) => #{ ValuaChange(itemId, name, intCount, value). }

        case (_,_) => #{}

    }


}
