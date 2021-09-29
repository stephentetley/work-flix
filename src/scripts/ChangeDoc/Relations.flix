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
    


    /// Relations derived from "ChangeAttrs"
    
    pub rel FunclocChange(itemId: String, attrName: String, change: String, value: String)

    pub rel FlocLongTextChange(itemId: String, language: String, attrName: String, change: String, value: String)

    pub rel FlocClassChange(itemId: String, className: String, classType: String, attrName: String, change: String, value: String)

    pub rel FlocCharChange(itemId: String, charName: String, classType: String, intCounter: Int32, attrName: String, change: String, value: String)

    pub rel EquipmentChange(itemId: String, attrName: String, change: String, value: String)

    pub rel EquiLongTextChange(itemId: String, language: String,attrName: String, change: String, value: String)

    pub rel EquiClassChange(itemId: String, className: String, classType: String, attrName: String, change: String, value: String)

    pub rel EquiCharChange(itemId: String, charName: String, classType: String, intCounter: Int32, attrName: String, change: String, value: String)



    /// entity should be "Floc" or "Equi"
    pub rel NameChange(entity: String, itemId: String, name: String)

    
    pub rel AttrChange(entity: String, itemId: String, name: String, value: String)
    
    pub rel ClassChange(entity: String, itemId: String, className: String, status: String)

    pub rel LongTextChange(entity: String, itemId: String, attribute: String, value: String)

    pub rel ValuaChange(entity: String, itemId: String, charName: String, intCounter: Int32, value: String, status: String)

    pub rel Funcloc(internalId: String, functionalLocation: String, description: String)

    pub rel Equipment(equiId: String, description: String)

    pub rel FlocWorkItem(internalFloc: String, funcloc: String, description: String)

    pub rel EquiWorkItem(equiId: String, description: String, funcloc: String)

    

    pub rel FlocLongText(equiId: String, description: String, longText: String)

    pub rel EquiLongText(equiId: String, description: String, longText: String)


    pub rel ObjectType(itemId: String, objType: String)

    pub rel Attribute(itemId: String, attrName: String, attrValue: String)
    
    pub rel ClassFloc(itemId: String, funcloc: String, flocName: String, className: String, status: String)

    pub rel ClassEqui(itemId: String, equiName: String, className: String, status: String)

    pub rel ValuaFloc(itemId: String, funcloc: String, flocName: String, className: String, charName: String, intCounter: Int32, status: String, value: String)

    pub rel ValuaEqui(itemId: String, equiName: String, className: String, charName: String, intCounter: Int32, status: String, value: String)




}
