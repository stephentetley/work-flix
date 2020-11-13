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

namespace AutoLifting/SetupDb {

    use BasicDb.DbMonad;
 
    use AssetLib/S4/FileIO/ZTable/ExportDb.ZTableSourcePaths;

    type alias MappingTablePaths = 
        { siteMappingPath: System.FilePath
        , typeMappingPath: System.FilePath
        , workingLoadMappingPath: System.FilePath
        }

    pub def setupStaticTables(equiClassExport: System.FilePath, ztablePaths: ZTableSourcePaths, mappingTables: MappingTablePaths):  DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return};
        use AssetLib/S4/FileIO/ClassList/ExportDb.{defaultTableNames => classTableNames, storeEquiClassFile};
        use AssetLib/S4/FileIO/ZTable/ExportDb.{defaultTableNames => ztableNames, storeZTableFiles};
        use AutoLifting/SetupDb/SiteMapping.{storeSiteMapping};
        use AutoLifting/SetupDb/TypeMapping.{storeTypeMapping};
        use AutoLifting/SetupDb/WorkingLoadMapping.{storeWorkingLoadMapping};
        let* _  = storeEquiClassFile(classTableNames(), true, equiClassExport, Text/Charset.iso_8859_1());
        let* _  = storeZTableFiles(ztableNames(), ztablePaths);
        let* _  = storeSiteMapping("lookup_site", mappingTables.siteMappingPath);
        let* _  = storeTypeMapping("lookup_lifting_type", mappingTables.typeMappingPath);
        let* _  = storeWorkingLoadMapping("lookup_working_load", mappingTables.workingLoadMappingPath);
        return()



    type alias DownloadFilePaths = 
        { equiPath: System.FilePath
        , eqmltxtPath: System.FilePath
        , classEquiPath: System.FilePath
        , valuaEquiPath: System.FilePath
        }

    type alias WorklistPaths = 
        { worklistPath: System.FilePath
        , attribsPath: System.FilePath
        , memosPath: System.FilePath
        }


    pub def setupSpecificTables(worklistPaths: WorklistPaths, downloads: DownloadFilePaths):  DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return};
        use AssetLib/S4/Simple/EquiDownload.{storeEquiFile};
        use AssetLib/S4/FileIO/DownloadFile/Builtins.{storeEqmltxtFile, storeClassEquiFile, storeValuaEquiFile};
        use AutoLifting/SetupDb/Worklist.{storeWorklist};
        use AutoLifting/SetupDb/ParentRef.{storeParentRefs};
        use AutoLifting/SetupDb/AibAttributes.{storeAibAttributes};
        use AutoLifting/SetupDb/MemoLines.{storeMemoLines};
        let* _  = storeEquiFile("df_equi", true, downloads.equiPath);
        let* _  = storeEqmltxtFile("df_eqmltxt", true, downloads.eqmltxtPath);
        let* _  = storeClassEquiFile("df_classequi", true, downloads.classEquiPath);
        let* _  = storeValuaEquiFile("df_valuaequi", true, downloads.valuaEquiPath);
        let* _  = storeWorklist("wl_worklist", worklistPaths.worklistPath);
        let* _  = storeParentRefs("wl_parent_refs", worklistPaths.worklistPath);
        let* _  = storeAibAttributes("wl_attributes", worklistPaths.attribsPath); 
        let* _  = storeMemoLines("wl_memo_lines", worklistPaths.memosPath);
        return()


}