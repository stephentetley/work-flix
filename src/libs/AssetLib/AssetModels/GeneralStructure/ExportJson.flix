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

namespace AssetLib/AssetModels/GeneralStructure/ExportJson {

    use BasicJson.JsonValue;
    use BasicJson/JsonBuilder.JsObject;

    use AssetLib/AssetModels/GeneralStructure/Datatypes.{GSSite, GSFunction, 
        GSProcessGroup, GSProcess, GSSystem, GSSubsystem, GSEquipment, GSSubequipment};

    /// This is very slow, must find out whether it is building the JSON / pretty printing it / ...

    pub def exportJson(path: System.FilePath, x: GSSite): Result[Unit, String] & Impure =
        let _ = Console.printLine("Building JSON... ${Time/LocalTime.now()}");
        let json1 = putSite(x) |> BasicJson/JsonBuilder.objectOf;
        let _ = Console.printLine("Writing JSON... ${Time/LocalTime.now()}");
        BasicJson/Pretty.writeJson(path, json1)


    pub def putSite(x: GSSite): JsObject = 
        use BasicJson/JsonBuilder.{createObject, putField, arrayOf, objectOf};
        createObject()
            |> putField("funcloc", x.funcloc)
            |> putField("name", x.name)
            |> putField("objectType", "SITE")
            |> putField("status", x.status)
            |> putField("functions", arrayOf(List.map(putFunction >> objectOf, x.functions)))
        
    pub def putFunction(x: GSFunction): JsObject = 
        use BasicJson/JsonBuilder.{createObject, putField, arrayOf, objectOf};
        createObject()
            |> putField("funcloc", x.funcloc)
            |> putField("name", x.name)
            |> putField("objectType", x.objectType)
            |> putField("status", x.status)
            |> putField("process_groups", arrayOf(List.map(putProcessGroup >> objectOf, x.processGroups)))
    
    pub def putProcessGroup(x: GSProcessGroup): JsObject = 
        use BasicJson/JsonBuilder.{createObject, putField, arrayOf, objectOf};
        createObject()
            |> putField("funcloc", x.funcloc)
            |> putField("name", x.name)
            |> putField("objectType", x.objectType)
            |> putField("status", x.status)
            |> putField("process_groups", arrayOf(List.map(putProcess >> objectOf, x.processes)))

    pub def putProcess(x: GSProcess): JsObject = 
        use BasicJson/JsonBuilder.{createObject, putField, arrayOf, objectOf};
        createObject()
            |> putField("funcloc", x.funcloc)
            |> putField("name", x.name)
            |> putField("objectType", x.objectType)
            |> putField("status", x.status)
            |> putField("process", arrayOf(List.map(putSystem >> objectOf, x.systems)))

    pub def putSystem(x: GSSystem): JsObject = 
        use BasicJson/JsonBuilder.{createObject, putField, arrayOf, objectOf};
        createObject()
            |> putField("funcloc", x.funcloc)
            |> putField("name", x.name)
            |> putField("objectType", x.objectType)
            |> putField("status", x.status)
            |> putField("subsystems", arrayOf(List.map(putSubsystem >> objectOf, x.subsystems)))
            |> putField("equipment", arrayOf(List.map(putEquipment >> objectOf, x.equipment)))

    pub def putSubsystem(x: GSSubsystem): JsObject = 
        use BasicJson/JsonBuilder.{createObject, putField, arrayOf, objectOf};
        createObject()
            |> putField("funcloc", x.funcloc)
            |> putField("name", x.name)
            |> putField("objectType", x.objectType)
            |> putField("status", x.status)
            |> putField("equipment", arrayOf(List.map(putEquipment >> objectOf, x.equipment)))

    pub def putEquipment(x: GSEquipment): JsObject = 
        use BasicJson/JsonBuilder.{createObject, putField, arrayOf, objectOf};
        createObject()
            |> putField("equiId", x.equiId)
            |> putField("name", x.name)
            |> putField("objectType", x.objectType)
            |> putField("status", x.status)
            |> putField("position", showPosition(x.position))
            |> putField("subequipment", arrayOf(List.map(putSubEquipment >> objectOf, x.subequipment)))


    pub def putSubEquipment(x: GSSubequipment): JsObject = 
        use BasicJson/JsonBuilder.{createObject, putField};
        createObject()
            |> putField("equiId", x.equiId)
            |> putField("name", x.name)
            |> putField("objectType", x.objectType)
            |> putField("status", x.status)
            |> putField("position", showPosition(x.position))
        
    def showPosition(pos: Option[Int32]): String = match pos {
        case Some(n) => String.padLeft(4, '0', ToString.toString(n))
        case None => ""
    }

}
