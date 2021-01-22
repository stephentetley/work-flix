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

/// TODO use GetOpt
def main(_args: Array[String]): Int32 & Impure =  
    use BasicDb/DbMonad.{runSQLite};
    
    use AssetLib/S4/FileIO/ZTable/ExportDb.ZTableSourcePaths;
    use NewLiftingItems/SetupDb.{MappingTablePaths, setupStaticTables};

    let outpath         = System/FilePath.new("G:/work/assets/lifting-equipment-2021/lifting_db.sqlite");
    let equiClassFacts = System/FilePath.new("G:/work/assets/facts/equi-class-export.txt");
    
    let ztableSourcePaths: ZTableSourcePaths = 
        { eqobjlPath    = System/FilePath.new("G:/work/assets/facts/ztables/ztable_eqobjl.txt")
        , flocdesPath   = System/FilePath.new("G:/work/assets/facts/ztables/ztable_flocdes.txt")
        , floobjlPath   = System/FilePath.new("G:/work/assets/facts/ztables/ztable_floobjl.txt")
        , manufPath     = System/FilePath.new("G:/work/assets/facts/ztables/ztable_manuf.txt")
        , objPath       = System/FilePath.new("G:/work/assets/facts/ztables/ztable_obj.txt")
        };
    
    let mappingTablePaths: MappingTablePaths = 
        { siteMappingPath           = System/FilePath.new("G:/work/assets/facts/aib-installations-to-s4.xlsx")
        , typeMappingPath           = System/FilePath.new("G:/work/assets/lifting-equipment-reports/01.lifting_equipment_types.xlsx")
        , workingLoadMappingPath    = System/FilePath.new("G:/work/assets/lifting-equipment-reports/02.working_load_fields.xlsx")
        };

    match runSQLite(setupStaticTables(equiClassFacts, ztableSourcePaths, mappingTablePaths), outpath) { 
        case Ok() => {Console.printLine("Good - database created ${outpath}"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
    }


namespace NewLiftingItems/SetupDb {

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
        let* _  = storeEquiClassFile(classTableNames(), true, equiClassExport, Text/Charset.iso_8859_1());  /// still neeeded?
        let* _  = storeZTableFiles(ztableNames(), ztablePaths); /// still neeeded?
        let* _  = NewLiftingItems/SetupDb/Facts/SiteMapping.storeSiteMapping("lookup_site", mappingTables.siteMappingPath);
        let* _  = NewLiftingItems/SetupDb/Facts/TypeMapping.storeTypeMapping("lookup_lifting_type", mappingTables.typeMappingPath);
        let* _  = NewLiftingItems/SetupDb/Facts/WorkingLoadMapping.storeWorkingLoadMapping("lookup_working_load", mappingTables.workingLoadMappingPath);
        return()


}