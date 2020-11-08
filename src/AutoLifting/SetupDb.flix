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


    pub def setupSpecificTables(worklistPath: System.FilePath):  DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return};
        use AutoLifting/SetupDb/ParentRef.{storeParentRefs};
        let* _  = storeParentRefs("wl_parent_refs", worklistPath);
        return()


}