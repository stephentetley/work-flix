/*
 * Copyright 2020 Stephen Tetley
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


namespace AssetLib/FileIO/S4/IH06Tree/ExportJson {

    use Data.RoseTree;
    use Data.RoseTree.{RoseTree};

    use BasicJson/Syntax.JsonValue;
    use BasicJson/JsonBuilder.JsObject;

    use AssetLib/FileIO/S4/IH06Tree/Datatypes.{IH06Tree, IH06Node};
    use AssetLib/FileIO/S4/IH06Tree/Datatypes.IH06Node.{FlocNode, EquiNode};

    pub def exportJson(path: System.FilePath, xs: List[IH06Tree]): Result[Unit, String] & Impure =
        use BasicJson/JsonBuilder.{arrayOf};
        let jsonForest = List.map(jsonTree, xs) |> arrayOf;
        BasicJson/Pretty.writeJson(path, jsonForest)



    pub def jsonTree(node: RoseTree[IH06Node]): JsonValue = 
        use BasicJson/JsonBuilder.{putField, arrayOf, objectOf};
        match node {
            case RoseTree(label, kids) => { 
                let obj = makeNode(label);
                jsonKids(kids, vs -> obj |> putField("kids", arrayOf(List.map(objectOf, vs))))
            }
        } |> objectOf

    def jsonNode(node: RoseTree[IH06Node], k: JsObject -> JsObject): JsObject = 
        use BasicJson/JsonBuilder.{putField, arrayOf, objectOf};
        let RoseTree(label, kids) = node;
        let obj = makeNode(label);
        jsonKids(kids, vs -> k(obj |> putField("kids", arrayOf(List.map(objectOf, vs)))))

    def jsonKids(nodes: List[RoseTree[IH06Node]], k: List[JsObject] -> JsObject): JsObject = match nodes { 
        case Nil => k(Nil)
        case x :: rs => jsonNode(x, v1 -> jsonKids(rs, vs -> k(v1 :: vs)))
    }

    pub def makeNode(node: IH06Node): JsObject = 
        use BasicJson/JsonBuilder.{createObject, putField};
        match node { 
            case FlocNode(x1) =>
                createObject()
                    |> putField("type", "FLOC")
                    |> putField("level", x1.level)
                    |> putField("floc", x1.floc)
                    |> putField("description", x1.description)
            case EquiNode(x1) => 
                createObject()
                    |> putField("type", "EQUI")
                    |> putField("level", x1.level)
                    |> putField("equiId", x1.equiId)
                    |> putField("description", x1.description)
        }

}
