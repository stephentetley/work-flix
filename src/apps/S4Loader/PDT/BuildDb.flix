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

namespace S4Loader/Pdt/BuildDb {

    use BasicDb.DbMonad;

    use S4Loader/PDT/BuildDb/Schema.{UnitsType};

    /// Create tables...
    pub def initDb(): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, point};
        let* _  = S4Loader/Base/InitDb.createPropertiesTables();
        let* _  = S4Loader/Base/InitDb.createEquiClassListTables();
        let* _  = S4Loader/Base/InitDb.createMetaPDTTables();      
        point()


    /// Load from PDT Db and metadata
    pub def storeMetaData(x: {equiClassList :: System.FilePath, 
                                fieldUnitTypes :: System.FilePath}): DbMonad[#{UnitsType | r}] = 
        use BasicDb/DbMonad.{flatMap, point};
        let* _      = S4Loader/Base/InitDb.storeEquiClassListData(x.equiClassList);
        let* utypes = S4Loader/PDT/BuildDb/ReadConfigs.readAndStoreFieldUnitTypes(x.fieldUnitTypes);
        point(utypes)

}
