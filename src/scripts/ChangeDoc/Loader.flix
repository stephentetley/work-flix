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
    use ChangeDoc/Datatypes.ChangeKey.{EquiNameKey, FlocNameKey, 
        EquiClassKey, FlocClassKey, EquiAttrKey, FlocAttrKey,
        EquiCharDescrKey, FlocCharDescrKey, ZEquiaddrAttrKey, ZFuncloadAttrKey};
    use ChangeDoc/Datatypes.EntityType.{Equi, Floc};
    use ChangeDoc/Datatypes.Instruction.{New, Change, Delete};
    
    
    /// Rows are ordered by datetime

    /// Warning duplicate column names - "Address Number"




    pub def readChangeDoc(src: XlsxSource): Result[ChangeDoc, String] & Impure = 
        SheetIO/Reader.readSomeRows(src, evalRow())


    def evalRow(): RowEvaluator[Option[ChangeRow]] =
        use SheetIO/RowEvaluator.{flatMap, return, getColumnIndex, getTrimmedContentAt, optional};
        use SheetIO/RowEvaluator.{>>=};
        let* entityType     = optional(getEntityType());
        let* table          = getColumnIndex("R") >>= getTrimmedContentAt;
        match (entityType, table) {
            case (Some(et1), "Text Table") => evalName(et1)
            case (_, _) => return(None)
        }

    def evalName(entityType: EntityType): RowEvaluator[Option[ChangeRow]] =
        use SheetIO/RowEvaluator.{flatMap, return, getColumnIndex, getTrimmedContentAt, optional};
        use SheetIO/RowEvaluator.{>>=};
        let* equiId         = getColumnIndex("E") >>= getTrimmedContentAt;
        let* attribute      = getColumnIndex("O") >>= getTrimmedContentAt;
        let* change         = optional(getInstruction()); 
        match (attribute, entityType, change) {
            case ("Description (medium text)", Equi, Some(instr)) => return(Some(ChangeRow(EquiNameKey(equiId), instr)))
            case ("Description (medium text)", Floc, Some(instr)) => return(Some(ChangeRow(FlocNameKey(equiId), instr)))
            case (_, _, _) => return(None)
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
