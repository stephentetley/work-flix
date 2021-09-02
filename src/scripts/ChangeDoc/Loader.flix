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

    use ChangeDoc/Datatypes.{FlocWorkItem, EquiWorkItem, ChangeDoc, ChangeRow, Instruction, EntityType};
    use ChangeDoc/Datatypes.ChangeRow.{ChangeRow};
    use ChangeDoc/Datatypes.ChangeKey.{NameKey, ClassKey, 
        LongTextKey, AttrKey, ValuaKey, AddrAttrKey};
    use ChangeDoc/Datatypes.EntityType.{Equi, Floc};
    use ChangeDoc/Datatypes.Instruction.{New, Change, Delete};
    


    /// Needs a Change Request export of the Functional Location tab...
    /// Sheet always called "Data"
    ///
    pub def readFlocWorkItems(src: System.FilePath): Result[List[FlocWorkItem], String] & Impure = 
        SheetIO/Reader.readAllNamedRows({path = src, sheet = "Data"}, evalFlocWorkItem())


    def evalFlocWorkItem(): NamedRowEvaluator[FlocWorkItem] = 
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

    /// Rows are ordered by datetime
    /// Warning duplicate column names - "Address Number"
    /// Sheet always called "Data"
    pub def readChangeDoc(src: System.FilePath): Result[ChangeDoc, String] & Impure = 
        use SheetIO/SheetReader.{flatMap, getSheetNamed, namedRowsFrom};
        let action = {let* sheet1 = getSheetNamed("Data"); namedRowsFrom(sheet1, 2, 3, evalChangeRow())};
        SheetIO/SheetReader.runXlsx(action, src)
            |> Result.map(List.filterMap(identity))




    def evalChangeRow(): NamedRowEvaluator[Option[ChangeRow]] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, optional};
        let* entityType     = optional(getEntityType());
        let* table          = getTrimmedContentNamed("Table");
        match (entityType, table) {
            case (Some(entype), "Text Table") => evalNameChange(entype)
            case (Some(Equi),   "Table for Relationship CLASSEQUI") => evalClassChange(Equi)
            case (Some(Floc),   "Table for Relationship CLASSFLOC") => evalClassChange(Floc)
            case (Some(Equi),   "Table for Relationship EQMLTXT") => evalLongTextChange(Equi)
            case (Some(Floc),   "Table for Relationship IFLOTX") => evalLongTextChange(Floc)    /// "IFLOTX" needs checking
            case (Some(entype), "Check Table") => evalAttrChange(entype)
            case (Some(Equi),   "Table for Relationship VALUAEQUI") =>  evalCharacteristicChange(Equi)
            case (Some(Floc),   "Table for Relationship VALUAFLOC") =>  evalCharacteristicChange(Floc)
            case (Some(Equi),   "Table for Relationship ZEQUIADDR") =>  evalAddressChange(Equi)
            case (Some(Floc),   "Table for Relationship ZFUNCLOAD") =>  evalAddressChange(Floc)
            case (_, _) => return(None)
        }

    def evalNameChange(entityType: EntityType): NamedRowEvaluator[Option[ChangeRow]] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, optional};
        let* itemId         = getTrimmedContentNamed("Value");
        let* attribute      = getTrimmedContentNamed("Attribute");
        let* change         = optional(getInstruction()); 
        match (attribute, change) {
            case ("Description (medium text)", Some(instr)) => return(Some(ChangeRow(NameKey(entityType, itemId), instr)))
            case (_, _) => return(None)
        }

    def evalClassChange(entityType: EntityType): NamedRowEvaluator[Option[ChangeRow]] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, optional};
        let* itemId         = getTrimmedContentNamed("Value");
        let* className      = getTrimmedContentNamed("Class");
        let* attribute      = getTrimmedContentNamed("Attribute");
        let* change         = optional(getInstruction()); 
        match (attribute, change) {
            case ("Status", Some(instr)) => return(Some(ChangeRow(ClassKey(entityType, itemId, className), instr)))
            case (_, _) => return(None)
        }

    def evalAttrChange(entityType: EntityType): NamedRowEvaluator[Option[ChangeRow]] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, optional};
        let* itemId         = getTrimmedContentNamed("Value");
        let* attribute      = getTrimmedContentNamed("Attribute");
        let* change         = optional(getInstruction()); 
        match change {
            case Some(instr) => return(Some(ChangeRow(AttrKey(entityType, itemId, attribute), instr)))
            case _ => return(None)
        }


    def evalLongTextChange(entityType: EntityType): NamedRowEvaluator[Option[ChangeRow]] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, optional};
        let* itemId         = getTrimmedContentNamed("Value");
        let* attribute      = getTrimmedContentNamed("Attribute");
        let* change         = optional(getInstruction()); 
        match change {
            case Some(instr) => return(Some(ChangeRow(LongTextKey(entityType, itemId, attribute), instr)))
            case _ => return(None)
        }

    /// Valuafloc records "Functional Location" for New+Blank
    def evalCharacteristicChange(entityType: EntityType): NamedRowEvaluator[Option[ChangeRow]] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, optional};
        let* itemId         = getTrimmedContentNamed("Value");
        let* charName       = getTrimmedContentNamed("Character ID");
        let* attribute      = getTrimmedContentNamed("Attribute");
        let* counter        = getIntCounter();
        let* change         = optional(getInstruction()); 
        match (attribute, change) {
            case ("Description", Some(instr)) => return(Some(ChangeRow(ValuaKey(entityType, itemId, charName, counter), instr)))
            case ("Functional Location", Some(instr)) => return(Some(ChangeRow(ValuaKey(entityType, itemId, charName, counter), instr)))
            case _ => return(None)
        }

    def evalAddressChange(entityType: EntityType): NamedRowEvaluator[Option[ChangeRow]] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, optional};
        let* itemId         = getTrimmedContentNamed("Value");
        let* attribute      = getTrimmedContentNamed("Attribute");
        let* number         = getAddressNumber();
        let* change         = optional(getInstruction()); 
        match change {
            case Some(instr) => return(Some(ChangeRow(AddrAttrKey(entityType, itemId, attribute, number), instr)))
            case _ => return(None)
        }


    /// Helpers

    def getIntCounter(): NamedRowEvaluator[Int32] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, throwError};
        let* counter        = getTrimmedContentNamed("Int counter");
        match Int32.fromString(counter) {
            case Ok(i) => return(i)
            case Err(msg) => throwError("getIntCounter [${msg}] - `${counter}`")
        }

    /// Note - may or may not have two "Address Number" columns- it will not have content in both...
    def getAddressNumber(): NamedRowEvaluator[String] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, throwError};
        let* number        = getTrimmedContentNamed("Address Number");
        if (String.isEmpty(number)) {
            getTrimmedContentNamed("Address Number.1")
        } 
        else return(number)


    

    def getInstruction(): NamedRowEvaluator[Instruction] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getTrimmedContentNamed, throwError};
        use SheetIO/NamedRowEvaluator.{>>=};
        let* change         = getTrimmedContentNamed("Change");
        let* newValue       = getTrimmedContentNamed("New Value");
        match change {
            case "New" => return(New(newValue))
            case "Changed" => return(Change(newValue))
            case "Deleted" => return(Delete)
            case _ => throwError("getInstruction")
        }


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
