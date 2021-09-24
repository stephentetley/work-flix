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
    use ChangeDoc/InterpretChangeAttrs.{State};
    

    /// entity should be "Floc" or "Equi"
    pub rel NameChange(entity: String, itemId: String, name: String)

    
    pub rel AttrChange(entity: String, itemId: String, name: String, value: String)
    
    pub rel ClassChange(entity: String, itemId: String, className: String, status: String)

    pub rel LongTextChange(entity: String, itemId: String, attribute: String, value: String)

    pub rel ValuaChange(entity: String, itemId: String, charName: String, intCounter: Int32, value: String, status: String)

    pub rel Funcloc(internalId: String, functionalLocation: String, description: String)

    pub rel Equipment(equiId: String, description: String)

    pub rel FlocNameMap(internalFloc: String, funcloc: String)
    

    pub rel FlocLongText(equiId: String, description: String, longText: String)

    pub rel EquiLongText(equiId: String, description: String, longText: String)


    pub rel ObjectType(itemId: String, objType: String)

    pub rel Attribute(itemId: String, attrName: String, attrValue: String)
    
    pub rel ClassFloc(itemId: String, funcloc: String, flocName: String, className: String, status: String)

    pub rel ClassEqui(itemId: String, equiName: String, className: String, status: String)

    pub rel ValuaFloc(itemId: String, funcloc: String, flocName: String, className: String, charName: String, intCounter: Int32, status: String, value: String)

    pub rel ValuaEqui(itemId: String, equiName: String, className: String, charName: String, intCounter: Int32, status: String, value: String)

    pub def makeChangeRelations(st: State): #{NameChange, AttrChange, LongTextChange, ClassChange, ValuaChange | r} = 
        RelLib/Relation.foldMap(makeChangeRelation1, Map.toList(st))

    /// To do this should make relations that include value "state".
    def makeChangeRelation1(xy: (ChangeKey, ValueState)): #{NameChange, AttrChange, LongTextChange, ClassChange, ValuaChange | r} = match xy { 
        case (NameKey(entity, itemId), CreateLocal(name)) => #{ NameChange("${entity}", itemId, name). }
        case (NameKey(entity, itemId), UpdateGlobal(name)) => #{ NameChange("${entity}", itemId, name). }

        case (ClassKey(entity, itemId, className), CreateLocal(_)) => #{ ClassChange("${entity}", itemId, className, "New"). }
        case (ClassKey(entity, itemId, className), UpdateGlobal(_)) => #{ ClassChange("${entity}", itemId, className, "Update"). }
        case (ClassKey(entity, itemId, className), DeleteGlobal(_)) => #{ ClassChange("${entity}", itemId, className, "Delete"). }

        case (LongTextKey(entity, itemId, name), CreateLocal(value)) => #{ LongTextChange("${entity}", itemId, name, value). }
        case (LongTextKey(entity, itemId, name), UpdateGlobal(value)) => #{ LongTextChange("${entity}", itemId, name, value). }

        /// AttrChanges are merged into Flocs and Equis so we only care about Create/Update
        case (AttrKey(entity, itemId, attrName), CreateLocal(value)) => #{ AttrChange("${entity}", itemId, attrName, value). }
        case (AttrKey(entity, itemId, attrName), UpdateGlobal(value)) => #{ AttrChange("${entity}", itemId, attrName, value). }

        case (ValuaKey(entity, itemId, charName, intCount), CreateLocal(value)) => #{ ValuaChange("${entity}", itemId, charName, intCount, value, "New"). }
        case (ValuaKey(entity, itemId, charName, intCount), UpdateGlobal(value)) => #{ ValuaChange("${entity}", itemId, charName, intCount, value, "Update"). }
        case (ValuaKey(entity, itemId, charName, intCount), DeleteGlobal) => #{ ValuaChange("${entity}", itemId, charName, intCount, "", "Delete"). }

        case (_,_) => #{}

    }


}
