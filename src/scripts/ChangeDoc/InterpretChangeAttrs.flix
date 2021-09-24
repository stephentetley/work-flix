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


namespace ChangeDoc/InterpretChangeAttrs {

    use ChangeDoc/Datatypes.{ChangeDoc, ChangeRow, ChangeKey, Instruction, ValueState};
    use ChangeDoc/Datatypes.ChangeRow.{ChangeRow};

    use ChangeDoc/Datatypes.Instruction.{New, Delete, Change};

    use ChangeDoc/Datatypes.ValueState.{CreateLocal, DeleteLocal, 
        UpdateGlobal, DeleteGlobal};

    type alias State = Map[ChangeKey, ValueState]


    pub def interpret(changes: ChangeDoc): State = 
        List.foldLeft(interpret1, Map.empty(), changes)

    def interpret1(st: State, row: ChangeRow): State = 
        let ChangeRow(key, instr) = row;
        match (Map.get(key, st), instr) {
            /// `None` indicates first appearance in the patch stream
            case (None, New(v1))       => Map.insert(key, CreateLocal(v1), st)
            case (None, Change(v1))    => Map.insert(key, UpdateGlobal(v1), st)
            case (None, Delete)        => Map.insert(key, DeleteGlobal, st)

            /// `Some(_)` indicates already seen in the patch stream
            case (Some(x1), New(v1))       => Map.insert(key, newValue(v1, x1), st)
            case (Some(x1), Change(v1))    => Map.insert(key, changeValue(v1, x1), st)
            case (Some(x1), Delete)        => Map.insert(key, deleteValue(x1), st)
        }
        
    def newValue(x: String, st: ValueState): ValueState = match st {
        case CreateLocal(_)     => CreateLocal(x)
        case DeleteGlobal       => UpdateGlobal(x)
        case DeleteLocal        => CreateLocal(x)
        case UpdateGlobal(_)    => UpdateGlobal(x)      /// unreachable for valid patch sequence
    }

    def changeValue(x: String, st: ValueState): ValueState = match st {
        case CreateLocal(_)     => CreateLocal(x)
        case DeleteGlobal       => UpdateGlobal(x)      /// unreachable for valid patch sequence
        case DeleteLocal        => CreateLocal(x)      
        case UpdateGlobal(_)    => UpdateGlobal(x)
    }

    def deleteValue(st: ValueState): ValueState = match st {
        case CreateLocal(_)     => DeleteLocal
        case DeleteGlobal       => DeleteGlobal
        case DeleteLocal        => DeleteLocal
        case UpdateGlobal(_)    => DeleteGlobal
    }

}
