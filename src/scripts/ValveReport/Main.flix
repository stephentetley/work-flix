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

namespace ValveReport/Main {

    use AssetLib/AibRel/HierarchicalRelations.{RootNode, AibFloc, AibEquipment};
    use ValveReport/Relations.{ValveWorkItem, ValveAttribs};

    type alias XlsxSource = 
        { file: System.FilePath
        , sheet: String
        }

    type alias SourceFiles = 
        { uxlTemplate: System.FilePath
        , aibHierarchyExport: XlsxSource
        , aibValveExport: XlsxSource
        , aibAgaspExport: XlsxSource
        , aibMemosExport: XlsxSource
        , worklist: XlsxSource
        }

    pub def loadRelations(src: SourceFiles): Result[#{ValveAttribs, ValveWorkItem, RootNode, AibFloc, AibEquipment | r}, String] & Impure = 
        use Result.{flatMap};
        let* hrelns         = AssetLib/AibRel/HierarchicalRelations.readHierarchyRelations(src.aibHierarchyExport.sheet, src.aibHierarchyExport.file);
        let* valveAttribs   = ValveReport/Relations.readValveAttribsData(src.aibValveExport.sheet, src.aibValveExport.file);
        let* workitems      = ValveReport/Relations.readWorkItemData(src.worklist.sheet, src.worklist.file);
        Ok(hrelns <+> valveAttribs <+> workitems)

}
