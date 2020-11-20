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




    type alias WorklistPaths = 
        { worklist: System.FilePath
        , attributesExport: System.FilePath
        , memosExport: System.FilePath
        }

    type alias DownloadFilePaths = 
        { equiPath: System.FilePath
        , eqmltxtPath: System.FilePath
        , classEquiPath: System.FilePath
        , valuaEquiPath: System.FilePath
        }

    /// TODO - downloads should be Option[DownloadFilePaths]...
    pub def setupSpecificTables(worklistPaths: WorklistPaths, downloads: Option[DownloadFilePaths]):  DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return};
        use AssetLib/S4/Simple/EquiDownload.{initEquiTable, storeEquiFile};
        use AssetLib/S4/FileIO/DownloadFile/Builtins.{initEqmltxtTable, storeEqmltxtFile, 
            initClassEquiTable, storeClassEquiFile, initValuaEquiTable, storeValuaEquiFile};
        use AutoLifting/SetupDb/Worklist.{storeWorklist};
        use AutoLifting/SetupDb/ParentRef.{storeParentRefs};
        use AutoLifting/SetupDb/AibAttributes.{storeAibAttributes};
        use AutoLifting/SetupDb/MemoLines.{storeMemoLines};
        let*  _ = match downloads {
            case Some(x) => {
                let* _  = storeEquiFile("df_equi", true, x.equiPath);
                let* _  = storeEqmltxtFile("df_eqmltxt", true, x.eqmltxtPath);
                let* _  = storeClassEquiFile("df_classequi", true, x.classEquiPath);
                let* _  = storeValuaEquiFile("df_valuaequi", true, x.valuaEquiPath);
                return()
            }
            case None => {
                let* _  = initEquiTable("df_equi");
                let* _  = initEqmltxtTable("df_eqmltxt");
                let* _  = initClassEquiTable("df_classequi");
                let* _  = initValuaEquiTable("df_valuaequi");
                return()
            }
        };
        let* _  = storeWorklist("wl_worklist", worklistPaths.worklist);
        let* _  = storeParentRefs("wl_parent_refs", worklistPaths.worklist);
        let* _  = storeAibAttributes("wl_attributes", worklistPaths.attributesExport); 
        let* _  = storeMemoLines("wl_memo_lines", worklistPaths.memosExport);
        return()


}