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


namespace AssetLib/S4Lite/Internal/Phase2Renumber {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};

    type alias ChangeRequestRow = 
        { equipmentId: String           /// $Dollar number
        , description: String           /// Equipment name
        , functionalLocation: String
        , superOrdinateEqui: String     /// $Dollar number or blank
        }


    pub def renumber(sourceKeyMap: Map[String, String], 
                    crSheet: String, 
                    crPath: System.FilePath, 
                    xs: List[SLEquiCharacteristic]): Result[List[SLEquiCharacteristic], String] & Impure = 
        use Result.{flatMap};
        let* crKeyMap   = getChangeRequestKeyMap(crSheet, crPath);
        renumberHelper(sourceKeyMap, crKeyMap, xs)


    def renumberHelper(keyMap1: Map[String, String], 
                        keyMap2: Map[String, String], 
                        xs: List[SLEquiCharacteristic]): Result[List[SLEquiCharacteristic], String] = 
        use Result.{flatMap};
        let renumber1 = x -> { 
            let* descrKey   = Option.toOk(Map.get(x.equiId, keyMap1), "Cannot find 3-part name for '${x.equiId}'");
            let* dollarKey  = Option.toOk(Map.get(descrKey, keyMap2), "Cannot find dollar number for '${descrKey}'");
            Ok({equiId = dollarKey | x})
        };
        Result.traverse(renumber1, xs)



    /// Read from S4 Change Request Equi export file...
    def getChangeRequestKeyMap(sheetName: String, 
                                    path: System.FilePath): Result[Map[String, String], String] & Impure =
        SheetIO/SheetReader.runXlsx(readChangeRequest(sheetName), path)

    def readChangeRequest(sheetName: String): SheetReader[Map[String, String]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, evalChangeRequestRow());
        let dict    = makeCRKeyMap(xs);
        return(dict)


    def evalChangeRequestRow(): NamedRowEvaluator[ChangeRequestRow] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getNonEmptyContentNamed, getContentNamed}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>}; 
        ((x1, x2, x3, x4) -> 
            { equipmentId = x1
            , description = x2
            , functionalLocation = x3
            , superOrdinateEqui = x4
            })
            <&> map(String.trim, getNonEmptyContentNamed("Equipment"))
            <*> map(String.trim, getNonEmptyContentNamed("Description"))
            <*> map(String.trim, getNonEmptyContentNamed("Functional Location"))
            <*> map(String.trim, getContentNamed("Superord. Equipment"))


    def makeCRKeyMap(xs: List[ChangeRequestRow]): Map[String, String] = 
        let dict1 = buildKeyToDesc(xs);
        List.foldLeft((ac, x) ->  Map.insert(makeCRThreePartKey(x, dict1), x.equipmentId, ac), Map.empty(), xs)

    def buildKeyToDesc(xs: List[ChangeRequestRow]): Map[String, String] = 
        List.foldLeft((ac, x) -> Map.insert(x.equipmentId, x.description, ac), Map.empty(), xs)

    def makeCRThreePartKey(x: ChangeRequestRow, descs: Map[String, String]): String = 
        if (not String.isEmpty(x.superOrdinateEqui)) {
            let superDesc = Map.getWithDefault(x.equipmentId, "Impossible", descs);
            "${x.description}::${x.functionalLocation}::${superDesc}"
        } else "${x.description}::${x.functionalLocation}::NO_SUPER"


}
