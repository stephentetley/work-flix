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


namespace ChangeDoc/Loader {

    use SheetIO.NamedRowEvaluator;
    use SheetIO/Reader.{XlsxSource};

    use ChangeDoc/Datatypes.{FlocTabItem, EquiTabItem, ChangeDoc, ChangeRow, 
        Level1Attrs, LongTextAttrs, ClassAttrs, CharAttrs, EntityType};
    use ChangeDoc/Datatypes.ChangeRow.{Funcloc1, FunclocLongText, FunclocClass, FunclocChar, 
        Equipment1, EquipmentLongText, EquipmentClass, EquipmentChar};
    use ChangeDoc/Datatypes.EntityType.{Equi, Floc};
    
    


    /// Reads an export of the Change Request "Functional Location" tab.
    /// Sheet always called "Data"
    ///
    pub def readFlocTabItems(src: System.FilePath): Result[List[FlocTabItem], String] & Impure = 
        SheetIO/Reader.readAllNamedRows({path = src, sheet = "Data"}, evalFlocTabItem())


    def evalFlocTabItem(): NamedRowEvaluator[FlocTabItem] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5) -> 
            { internalFuncloc   = x1
            , funcloc           = x2
            , description       = x3
            , structureInd      = x4
            , objectType        = x5
            })
            <&> getTrimmedContentNamed("Int. Functional Location")
            <*> getTrimmedContentNamed("Functional Location")
            <*> getTrimmedContentNamed("Description")
            <*> getTrimmedContentNamed("Structure indicator")
            <*> getTrimmedContentNamed("Object Type")

    /// Reads an export of the Change Request "Equipment" tab.
    /// Sheet always called "Data"
    ///
    pub def readEquiTabItems(src: System.FilePath): Result[List[EquiTabItem], String] & Impure = 
        SheetIO/Reader.readAllNamedRows({path = src, sheet = "Data"}, evalEquiTabItem())


    def evalEquiTabItem(): NamedRowEvaluator[EquiTabItem] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6) -> 
            { equiId        = x1
            , description   = x2
            , funcloc       = x3
            , category      = x4
            , objectType    = x5
            , objectClass   = x6
            })
            <&> getTrimmedContentNamed("Equipment")
            <*> getTrimmedContentNamed("Description")
            <*> getTrimmedContentNamed("Functional Location")
            <*> getTrimmedContentNamed("Equipment category")
            <*> getTrimmedContentNamed("Object Type")
            <*> getTrimmedContentNamed("Object Type Class")


    /// Rows are ordered by datetime
    /// Warning duplicate column names - "Address Number"
    /// Sheet always called "Data"
    pub def readChangeDoc(src: System.FilePath): Result[ChangeDoc, String] & Impure = 
        use SheetIO/SheetReader.{flatMap, getSheetNamed, namedRowsFrom};
        let action = {let* sheet1 = getSheetNamed("Data"); namedRowsFrom(sheet1, 2, 3, evalChangeRow())};
        SheetIO/SheetReader.runXlsx(action, src)
            |> Result.map(List.filterMap(identity))




    def evalChangeRow(): NamedRowEvaluator[Option[ChangeRow]] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getRowNum, getTrimmedContentNamed, throwError, optional};
        use SheetIO/NamedRowEvaluator.{<&>};
        let* rowNum         = (x1 -> x1 + 1) <&> getRowNum();
        let* entityType     = optional(getEntityType());
        let* ident          = getTrimmedContentNamed("Value");
        let* table          = getTrimmedContentNamed("Table");
        match (entityType, table) {
            case (Some(Floc),   "Check Table") => (x1 -> Funcloc1(rowNum, ident, x1)) <&> evalLevel1Attrs()
            case (Some(Floc),   "Table for Relationship IFLOTX") => (x1 -> FunclocLongText(rowNum, ident, x1)) <&> evalLongTextAttrs()
            case (Some(Floc),   "Table for Relationship CLASSFLOC") => (x1 -> FunclocClass(rowNum, ident, x1)) <&> evalClassAttrs()
            case (Some(Floc),   "Table for Relationship VALUAFLOC") => (x1 -> FunclocChar(rowNum, ident, x1)) <&> evalCharAttrs()
            case (Some(Equi),   "Check Table") => (x1 -> Equipment1(rowNum, ident, x1)) <&> evalLevel1Attrs()
            case (Some(Equi),   "Table for Relationship EQMLTXT") => (x1 -> EquipmentLongText(rowNum, ident, x1)) <&> evalLongTextAttrs()
            case (Some(Equi),   "Table for Relationship CLASSEQUI") => (x1 -> EquipmentClass(rowNum, ident, x1)) <&> evalClassAttrs()
            case (Some(Equi),   "Table for Relationship VALUAEQUI") => (x1 -> EquipmentChar(rowNum, ident, x1)) <&> evalCharAttrs()
            /// case (Some(Equi),   "Table for Relationship ZEQUIADDR") =>  evalAddressChange(Equi)
            /// case (Some(Floc),   "Table for Relationship ZFUNCLOAD") =>  evalAddressChange(Floc)
            case (_, _) => throwError("none")
        } |> optional
  


    def evalLevel1Attrs(): NamedRowEvaluator[Level1Attrs] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5) -> 
            { change        = x1
            , attribute     = x2
            , oldValue      = x3
            , newValue      = x4
            , tableDest     = x5
            })
            <&> getTrimmedContentNamed("Change")
            <*> getTrimmedContentNamed("Attribute")
            <*> getTrimmedContentNamed("Old Value")
            <*> getTrimmedContentNamed("New Value")
            <*> getTrimmedContentNamed("Table")

    def evalLongTextAttrs(): NamedRowEvaluator[LongTextAttrs] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6) -> 
            { language      = x1
            , change        = x2
            , attribute     = x3
            , oldValue      = x4
            , newValue      = x5
            , tableDest     = x6
            })
            <&> getTrimmedContentNamed("Language.1")
            <*> getTrimmedContentNamed("Change")
            <*> getTrimmedContentNamed("Attribute")
            <*> getTrimmedContentNamed("Old Value")
            <*> getTrimmedContentNamed("New Value")
            <*> getTrimmedContentNamed("Table")

    def evalClassAttrs(): NamedRowEvaluator[ClassAttrs] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7) -> 
            { className     = x1
            , classType     = x2
            , change        = x3
            , attribute     = x4
            , oldValue      = x5
            , newValue      = x6
            , tableDest     = x7
            })
            <&> getTrimmedContentNamed("Class")
            <*> getTrimmedContentNamed("Class Type")
            <*> getTrimmedContentNamed("Change")
            <*> getTrimmedContentNamed("Attribute")
            <*> getTrimmedContentNamed("Old Value")
            <*> getTrimmedContentNamed("New Value")
            <*> getTrimmedContentNamed("Table")

    def evalCharAttrs(): NamedRowEvaluator[CharAttrs] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8) -> 
            { characterId   = x1
            , classType     = x2
            , intCounter    = x3
            , change        = x4
            , attribute     = x5
            , oldValue      = x6
            , newValue      = x7
            , tableDest     = x8
            })
            <&> getTrimmedContentNamed("Character ID")
            <*> getTrimmedContentNamed("Class Type")
            <*> getIntCounter()
            <*> getTrimmedContentNamed("Change")
            <*> getTrimmedContentNamed("Attribute")
            <*> getTrimmedContentNamed("Old Value")
            <*> getTrimmedContentNamed("New Value")
            <*> getTrimmedContentNamed("Table")

    /// Helpers

    def getIntCounter(): NamedRowEvaluator[Int32] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, throwError};
        let* counter        = getTrimmedContentNamed("Int counter");
        match Int32.fromString(counter) {
            case Ok(i) => return(i)
            case Err(msg) => throwError("getIntCounter [${msg}] - `${counter}`")
        }

    /// Note - may or may not have two "Address Number" columns- it will not have content in both...
    def _getAddressNumber(): NamedRowEvaluator[String] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, throwError};
        let* number        = getTrimmedContentNamed("Address Number");
        if (String.isEmpty(number)) {
            getTrimmedContentNamed("Address Number.1")
        } 
        else return(number)





    def getEntityType(): NamedRowEvaluator[EntityType] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, throwError};
        use SheetIO/NamedRowEvaluator.{>>=};
        let* entityType     = getTrimmedContentNamed("Entity Type");
        match entityType {
            case "Equipment" => return(Equi)
            case "Functional Location" => return(Floc)
            case _ => throwError("getEntityType")
        }

}
