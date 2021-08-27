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

    use SheetIO.RowEvaluator;
    use SheetIO/Reader.{XlsxSource};

    use ChangeDoc/Datatypes.{ChangeDoc, ChangeRow, Instruction, EntityType};
    use ChangeDoc/Datatypes.ChangeRow.{ChangeRow};
    use ChangeDoc/Datatypes.ChangeKey.{NameKey, ClassKey, 
        LongTextKey, AttrKey, ValuaKey, AddrAttrKey};
    use ChangeDoc/Datatypes.EntityType.{Equi, Floc};
    use ChangeDoc/Datatypes.Instruction.{New, Change, Delete};
    
    
    /// Rows are ordered by datetime

    /// Warning duplicate column names - "Address Number"



    /// Sheet always called "Data"
    pub def readChangeDoc(src: System.FilePath): Result[ChangeDoc, String] & Impure = 
        let xlsx = {path = src, sheet = "Data"};
        SheetIO/Reader.readSomeRows(xlsx, evalChangeRow())

    /// Needs a Change Request export of the Functional Location tab...
    /// Sheet always called "Data"
    ///
    pub def readFlocMapping(src: System.FilePath): Result[Map[String, String], String] & Impure = 
        use SheetIO/NamedRowEvaluator.{tuple2, getTrimmedContentNamed};
        let xlsx = {path = src, sheet = "Data"};
        let evalRow = tuple2(getTrimmedContentNamed("Int. Functional Location"), getTrimmedContentNamed("Functional Location"));
        SheetIO/Reader.readAllNamedRows(xlsx, evalRow) |> Result.map(List.toMap)


    def evalChangeRow(): RowEvaluator[Option[ChangeRow]] =
        use SheetIO/RowEvaluator.{flatMap, return, getColumnIndex, getTrimmedContentAt, optional};
        use SheetIO/RowEvaluator.{>>=};
        let* entityType     = optional(getEntityType());
        let* table          = getColumnIndex("R") >>= getTrimmedContentAt;
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

    def evalNameChange(entityType: EntityType): RowEvaluator[Option[ChangeRow]] =
        use SheetIO/RowEvaluator.{flatMap, return, getColumnIndex, getTrimmedContentAt, optional};
        use SheetIO/RowEvaluator.{>>=};
        let* itemId         = getColumnIndex("E") >>= getTrimmedContentAt;
        let* attribute      = getColumnIndex("O") >>= getTrimmedContentAt;
        let* change         = optional(getInstruction()); 
        match (attribute, change) {
            case ("Description (medium text)", Some(instr)) => return(Some(ChangeRow(NameKey(entityType, itemId), instr)))
            case (_, _) => return(None)
        }

    def evalClassChange(entityType: EntityType): RowEvaluator[Option[ChangeRow]] =
        use SheetIO/RowEvaluator.{flatMap, return, getColumnIndex, getTrimmedContentAt, optional};
        use SheetIO/RowEvaluator.{>>=};
        let* itemId         = getColumnIndex("E") >>= getTrimmedContentAt;
        let* className      = getColumnIndex("G") >>= getTrimmedContentAt;
        let* attribute      = getColumnIndex("O") >>= getTrimmedContentAt;
        let* change         = optional(getInstruction()); 
        match (attribute, change) {
            case ("Status", Some(instr)) => return(Some(ChangeRow(ClassKey(entityType, itemId, className), instr)))
            case (_, _) => return(None)
        }

    def evalAttrChange(entityType: EntityType): RowEvaluator[Option[ChangeRow]] =
        use SheetIO/RowEvaluator.{flatMap, return, getColumnIndex, getTrimmedContentAt, optional};
        use SheetIO/RowEvaluator.{>>=};
        let* itemId         = getColumnIndex("E") >>= getTrimmedContentAt;
        let* attribute      = getColumnIndex("O") >>= getTrimmedContentAt;
        let* change         = optional(getInstruction()); 
        match change {
            case Some(instr) => return(Some(ChangeRow(AttrKey(entityType, itemId, attribute), instr)))
            case _ => return(None)
        }


    def evalLongTextChange(entityType: EntityType): RowEvaluator[Option[ChangeRow]] =
        use SheetIO/RowEvaluator.{flatMap, return, getColumnIndex, getTrimmedContentAt, optional};
        use SheetIO/RowEvaluator.{>>=};
        let* itemId         = getColumnIndex("E") >>= getTrimmedContentAt;
        let* attribute      = getColumnIndex("O") >>= getTrimmedContentAt;
        let* change         = optional(getInstruction()); 
        match change {
            case Some(instr) => return(Some(ChangeRow(LongTextKey(entityType, itemId, attribute), instr)))
            case _ => return(None)
        }


    def evalCharacteristicChange(entityType: EntityType): RowEvaluator[Option[ChangeRow]] =
        use SheetIO/RowEvaluator.{flatMap, return, getColumnIndex, getTrimmedContentAt, optional};
        use SheetIO/RowEvaluator.{>>=};
        let* itemId         = getColumnIndex("E") >>= getTrimmedContentAt;
        let* charName       = getColumnIndex("F") >>= getTrimmedContentAt;
        let* attribute      = getColumnIndex("O") >>= getTrimmedContentAt;
        let* counter        = getIntCounter();
        let* change         = optional(getInstruction()); 
        match (attribute, change) {
            case ("Description", Some(instr)) => return(Some(ChangeRow(ValuaKey(entityType, itemId, charName, counter), instr)))
            case _ => return(None)
        }

    def evalAddressChange(entityType: EntityType): RowEvaluator[Option[ChangeRow]] =
        use SheetIO/RowEvaluator.{flatMap, return, getColumnIndex, getTrimmedContentAt, optional};
        use SheetIO/RowEvaluator.{>>=};
        let* itemId         = getColumnIndex("E") >>= getTrimmedContentAt;
        let* attribute      = getColumnIndex("O") >>= getTrimmedContentAt;
        let* number         = getAddressNumber(entityType);
        let* change         = optional(getInstruction()); 
        match change {
            case Some(instr) => return(Some(ChangeRow(AddrAttrKey(entityType, itemId, attribute, number), instr)))
            case _ => return(None)
        }


    /// Helpers

    def getIntCounter(): RowEvaluator[Int32] =
        use SheetIO/RowEvaluator.{flatMap, return, getColumnIndex, getTrimmedContentAt, throwError};
        use SheetIO/RowEvaluator.{>>=};
        let* counter        = getColumnIndex("K") >>= getTrimmedContentAt;
        match Int32.fromString(counter) {
            case Ok(i) => return(i)
            case Err(msg) => throwError("getIntCounter [${msg}] - `${counter}`")
        }


    def getAddressNumber(entity: EntityType): RowEvaluator[Int32] =
        use SheetIO/RowEvaluator.{flatMap, return, getColumnIndex, getTrimmedContentAt, throwError};
        use SheetIO/RowEvaluator.{>>=};
        let column          = match entity {
            case Equi => "L"
            case Floc => "M"
        };
        let* number        = getColumnIndex(column) >>= getTrimmedContentAt;
        match Int32.fromString(number) {
            case Ok(i) => return(i)
            case Err(msg) => throwError("getAddressNumber [${msg}] - `${number}`")
        }


    def getInstruction(): RowEvaluator[Instruction] =
        use SheetIO/RowEvaluator.{flatMap, return, getColumnIndex, getTrimmedContentAt, throwError};
        use SheetIO/RowEvaluator.{>>=};
        let* change         = getColumnIndex("N") >>= getTrimmedContentAt;
        let* newValue       = getColumnIndex("Q") >>= getTrimmedContentAt;
        match change {
            case "New" => return(New(newValue))
            case "Changed" => return(Change(newValue))
            case "Deleted" => return(Delete)
            case _ => throwError("getInstruction")
        }


    def getEntityType(): RowEvaluator[EntityType] =
        use SheetIO/RowEvaluator.{flatMap, return, getColumnIndex, getTrimmedContentAt, throwError};
        use SheetIO/RowEvaluator.{>>=};
        let* entityType     = getColumnIndex("D") >>= getTrimmedContentAt;
        match entityType {
            case "Equipment" => return(Equi)
            case "Functional Location" => return(Floc)
            case _ => throwError("getEntityType")
        }

}
