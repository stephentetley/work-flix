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
    

    pub rel FlocNameChange(itemId: String, name: String)
    pub rel EquiNameChange(itemId: String, name: String)



    pub rel Funcloc(internalId: String, functionalLocation: String, description: String)

    pub rel Equipment(equiId: String, description: String)


    pub def makeChangeRelations(st: State): #{FlocNameChange, EquiNameChange | r} = 
        Relation.foldMap(makeChangeRelation1, Map.toList(st))

    def makeChangeRelation1(xy: (ChangeKey, ValueState)): #{FlocNameChange, EquiNameChange | r} = match xy { 
        case (NameKey(Floc, itemId), CreateLocal(name)) => #{ FlocNameChange(itemId, name). }
        case (NameKey(Floc, itemId), UpdateGlobal(name)) => #{ FlocNameChange(itemId, name). }
        case (NameKey(Equi, itemId), CreateLocal(name)) => #{ EquiNameChange(itemId, name). }
        case (NameKey(Equi, itemId), UpdateGlobal(name)) => #{ EquiNameChange(itemId, name). }
        case (_,_) => #{}

    }


}
