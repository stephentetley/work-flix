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
        LongTextKey, AttrKey, ValuaKey, AddrAttrKey};
    use ChangeDoc/Datatypes.EntityType.{Equi, Floc};
    use ChangeDoc/Datatypes.ValueState.{CreateLocal, DeleteLocal, 
        UpdateGlobal, DeleteGlobal};
    use ChangeDoc/Interpreter.{State};
    
    /// entity should be "Floc" or "Equi"
    pub rel NameChange(entity: String, itemId: String, name: String)

    
    pub rel AttrChange(itemId: String, name: String, value: String)
    
    pub rel ClassChange(entity: String, itemId: String, className: String, status: String)

    pub rel LongTextChange(entity: String, itemId: String, attribute: String, value: String)

    pub rel ValuaChange(entity: String, itemId: String, charName: String, intCounter: Int32, value: String)

    pub rel Funcloc(internalId: String, functionalLocation: String, description: String)

    pub rel Equipment(equiId: String, description: String)

    pub rel FlocNameMap(internalFloc: String, funcloc: String)

    pub rel FlocLongText(equiId: String, description: String, longText: String)

    pub rel EquiLongText(equiId: String, description: String, longText: String)


    pub rel ObjectType(itemId: String, objType: String)

    pub rel Attribute(itemId: String, attrName: String, attrValue: String)
    
    pub rel ClassFloc(itemId: String, funcloc: String, name: String, status: String)

    pub rel ClassEqui(itemId: String, name: String, status: String)

    pub rel ValuaFloc(itemId: String, name: String, intCounter: Int32, value: String)

    pub rel ValuaEqui(itemId: String, name: String, intCounter: Int32, value: String)

    pub def makeChangeRelations(st: State): #{NameChange, AttrChange | r} = 
        Relation.foldMap(makeChangeRelation1, Map.toList(st))

    /// To do this should make relations that include value "state".
    def makeChangeRelation1(xy: (ChangeKey, ValueState)): #{NameChange, AttrChange | r} = match xy { 
        case (NameKey(entity, itemId), CreateLocal(name)) => #{ NameChange("${entity}", itemId, name). }
        case (NameKey(entity, itemId), UpdateGlobal(name)) => #{ NameChange("${entity}", itemId, name). }

        case (ClassKey(entity, itemId, className), CreateLocal(_)) => #{ ClassChange("${entity}", itemId, className, "New"). }
        case (ClassKey(entity, itemId, className), UpdateGlobal(_)) => #{ ClassChange("${entity}", itemId, className, "Update"). }
        case (ClassKey(entity, itemId, className), DeleteGlobal(_)) => #{ ClassChange("${entity}", itemId, className, "Delete"). }

        case (LongTextKey(entity, itemId, name), CreateLocal(value)) => #{ LongTextChange("${entity}", itemId, name, value). }
        case (LongTextKey(entity, itemId, name), UpdateGlobal(value)) => #{ LongTextChange("${entity}", itemId, name, value). }

        case (AttrKey(_, itemId, name), CreateLocal(value)) => #{ AttrChange(itemId, name, value). }
        case (AttrKey(_, itemId, name), UpdateGlobal(value)) => #{ AttrChange(itemId, name, value). }

        case (ValuaKey(entity, itemId, name, intCount), CreateLocal(value)) => #{ ValuaChange("${entity}", itemId, name, intCount, value). }
        case (ValuaKey(entity, itemId, name, intCount), UpdateGlobal(value)) => #{ ValuaChange("${entity}", itemId, name, intCount, value). }

        case (_,_) => #{}

    }


}
