/*
 * Copyright 2022 Stephen Tetley
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

namespace S4Loader/PDT/BuildDb {

    use BasicDb.DbMonad;

    use S4Loader/PDT/BuildDb/Schema.{FieldType};

    /// Create tables...
    pub def initDb(): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, point};
        let* _  = S4Loader/Base/InitDb.createPropertiesTables();
        let* _  = S4Loader/Base/InitDb.createEquiClassListTables();
        let* _  = AssetLib/FileIO/Configuration/PDT/ReadAssetTypesCsv.createMetaPdtAssetTypesTable();
        let* _  = AssetLib/FileIO/Configuration/PDT/ReadFieldTypesCsv.createMetaPdtFieldTypesTable();
        let* _  = AssetLib/FileIO/Configuration/PDT/ReadOtoMappingsCsv.createMetaPdtOtoMappingsTable();
        let* _  = S4Loader/Base/InitDb.createPdtViews();
        point()


    /// Load from PDT Db and metadata
    pub def storeMetaData(x: {equiClassList :: System.FilePath, 
                                fieldTypes :: System.FilePath,
                                assetTypes :: System.FilePath, 
                                otoMappings :: System.FilePath}): DbMonad[#{FieldType | r}] = 
        use BasicDb/DbMonad.{flatMap, point};
        let* _          = S4Loader/Base/InitDb.storeEquiClassListData(x.equiClassList);
        let* _          = AssetLib/FileIO/Configuration/PDT/ReadAssetTypesCsv.readAndStoreAssetTypes(x.assetTypes);
        let* xs         = AssetLib/FileIO/Configuration/PDT/ReadFieldTypesCsv.readAndStoreFieldTypes(x.fieldTypes);
        let fieldtypes  = RelLib/Relation.foldMap(x1 -> #{ FieldType(x1.pdtFieldName, x1.propertyType). }, xs);
        let* _          = AssetLib/FileIO/Configuration/PDT/ReadOtoMappingsCsv.readAndStoreOtoMappings(x.otoMappings);
        point(fieldtypes)

}
