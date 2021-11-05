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


/// Export JSON from relations...


namespace AssetLib/Aruba/S4/ExportJson2 {

    use BasicJson.JsonValue;
    use BasicJson.JsonValue.{JsonArray, JsonObject};
    use BasicJson/JsonBuilder.JsObject;

    use AssetLib/Aruba/S4Hierarchy.{Site, Function, ProcessGroup, Process, 
        System, Subsystem, Equipment, S4FlocType, S4EquiType, ChildFloc, ChildEquipment, FunctionalLocation};



    
    pub type alias JsonSchema[r1: SchemaRow] =
        #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, 
                S4FlocType, S4EquiType, ChildFloc, ChildEquipment, FunctionalLocation | r1}

    pub def siteToJson(facts: JsonSchema[r]): JsonValue = 
        let facts1 = facts as  #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, 
                                    S4FlocType, S4EquiType, ChildFloc, ChildEquipment, FunctionalLocation, JsonRow | r};
        (query facts1 <+> jsonRowRules() select (x1, x2, x3, x4, x5, x6, x7) from JsonRow(x1, x2, x3, x4, x5, x6, x7)
            |> makeJsonFromRows("")) as & Pure


    rel JsonRow(key: String, rowType: String, nodeType: String, name: String, uid: String, kidsName: String, parent: String)

    type alias PreorderRow = (String, String, String, String, String, String, String)
    

    ///
    def jsonRowRules(): #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, 
                                S4FlocType, S4EquiType, ChildFloc, ChildEquipment, FunctionalLocation, JsonRow | r1} = #{


        /// Unbounded tree - including equipment at various levels and subequipment.
        JsonRow(siteFloc, "FLOC", "SITE", name, flocId, "functions", "") :- 
            Site(flocId, siteFloc, name).

        JsonRow(funFloc, "FLOC", flocType, name, flocId, "process_groups", siteFloc) :- 
            Function(flocId, funFloc, name),
            FlocType(flocId, flocType),
            ChildFloc(siteFloc, funFloc).

        JsonRow(pgFloc, "FLOC", flocType, name, flocId, "processes", funFloc) :- 
            ProcessGroup(flocId, pgFloc, name), 
            FlocType(flocId, flocType),
            ChildFloc(funFloc, pgFloc).

        JsonRow(pFloc, "FLOC", flocType, name, flocId, "systems", pgFloc) :- 
            Process(flocId, pFloc, name),
            FlocType(flocId, flocType), 
            ChildFloc(pgFloc, pFloc).

        JsonRow(sysFloc, "FLOC", flocType, name, flocId, "subsystems", pFloc) :- 
            System(flocId, sysFloc, name), 
            FlocType(flocId, flocType),
            ChildFloc(pFloc, sysFloc).

        JsonRow(ssFloc, "FLOC", flocType, name, flocId, "", sysFloc) :- 
            Subsystem(flocId, ssFloc, name), 
            FlocType(flocId, flocType),
            ChildFloc(sysFloc, ssFloc).
        
        JsonRow("${floc}::${equiId}", "EQUI", equiType, name, equiId, "", floc) :-
            Equipment(equiId, name, floc), 
            EquiType(equiId, equiType),
            not IsSubEquipment(equiId).

        JsonRow("${floc}::${superId}::${equiId}", "EQUI", equiType, name, equiId, "", "${floc}::${superId}") :-
            Equipment(equiId, name, floc), 
            EquiType(equiId, equiType),
            ChildEquipment(superId, equiId).

        IsSubEquipment(equiId) :- 
            Equipment(equiId, _, _), 
            ChildEquipment(_, equiId).


        FlocType(flocId, flocType) :- 
            FunctionalLocation(flocId, _), 
            S4FlocType(flocId, flocType).

        FlocType(flocId, "<UNKNOWN>") :- 
            FunctionalLocation(flocId, _), 
            not HasS4FlocType(flocId).

        HasS4FlocType(flocId) :- 
            FunctionalLocation(flocId, _), 
            S4FlocType(flocId, _).


        EquiType(equiId, "<UNKNOWN>") :- 
            Equipment(equiId, _, _), 
            not HasS4EquiType(equiId).

        EquiType(equiId, equiType) :- 
            Equipment(equiId, _, _), 
            S4EquiType(equiId, equiType).

        HasS4EquiType(equiId) :- 
            Equipment(equiId, _, _), 
            S4EquiType(equiId, _).

    }




    /// `rootKey` is the parent key of the topmost element(s), it should not be present as an item key.
    def makeJsonFromRows(rootKey: String, rows: Array[PreorderRow]): JsonValue & Impure =  
        treesList(rootKey, Array.toList(rows), (flocs, _, _) -> flocs) 
            |> BasicJson/JsonBuilder.arrayOfObject


    /// This is preorder builder with unlimited depth - input *must* be correctly ordered.
    def treesList(parentId: String, xs: List[PreorderRow], k: (List[JsObject], List[JsObject], List[PreorderRow]) -> List[JsObject]): List[JsObject] =
        match xs { 
            case r1 :: rest => {
                let (key, rowType, nodeType, name, uid, kidsName, parentKey) = r1;
                if (parentId == parentKey)
                    treesList(key, rest, (flocKids, equiKids, rest1) -> 
                        if (rowType == "FLOC") {
                            let node =  makeFlocNode(name, uid, nodeType, kidsName, flocKids, equiKids);
                            treesList(parentId, rest1, (flocSiblings, equiSiblings, rest2) -> k(node :: flocSiblings, equiSiblings, rest2))
                        } else {
                            let node =  makeEquiNode(name, uid, nodeType, equiKids);
                            treesList(parentId, rest1, (flocSiblings, equiSiblings, rest2) -> k(flocSiblings, node :: equiSiblings, rest2))
                        })
                else
                    k(Nil, Nil, xs)
            }
            case Nil => k(Nil, Nil, Nil)
        }

    def makeFlocNode(name: String, funcloc: String, nodeType: String, flocKidsName: String, flocKids: List[JsObject], equiKids: List[JsObject]): JsObject = 
        use BasicJson/JsonBuilder.{createObject, putField, arrayOfObject, objectOf};
        /// TODO - JsonBuilder should have conditional "put", maybe it should be a monad...
        if (not String.isEmpty(flocKidsName)) 
            createObject()
                |> putField("funcloc", funcloc)
                |> putField("name", name)
                |> putField("flocType", nodeType)
                |> putField(flocKidsName, arrayOfObject(flocKids))
                |> putField("equipment", arrayOfObject(equiKids))
        else                
            createObject()
                |> putField("funcloc", funcloc)
                |> putField("name", name)
                |> putField("objectType", nodeType)
                |> putField("equipment", arrayOfObject(equiKids))

    def makeEquiNode(name: String, uid: String, nodeType: String, equiKids: List[JsObject]): JsObject = 
        use BasicJson/JsonBuilder.{createObject, putField, arrayOfObject, objectOf};
        createObject()
            |> putField("equiId", uid)
            |> putField("name", name)
            |> putField("equiType", nodeType)
            |> putField("subequipment", arrayOfObject(equiKids))



}
