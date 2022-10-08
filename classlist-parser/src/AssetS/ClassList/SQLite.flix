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


namespace AssetS/ClassList/SQLite {

    use Applicative.{*>};

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetS/ClassList/Datatypes.{ClassRecords, ClassDescription, Characteristic, PicklistValue, IntRange};

    pub type alias ClassListTableNames = 
        { classDescriptionTable :: String
        , characteristicTable :: String
        , picklistValueTable :: String
        , intRangeTable :: String
        }


    pub def createClassListTables(names: ClassListTableNames): DbMonad[r, ka, Unit] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit!, executeSql!, commit!};
        let* _  = setAutoCommit!(false);
        let* _  = executeSql!("DROP TABLE IF EXISTS ${names.classDescriptionTable};");
        let* _  = executeSql!("DROP TABLE IF EXISTS ${names.characteristicTable};");
        let* _  = executeSql!("DROP TABLE IF EXISTS ${names.picklistValueTable};");
        let* _  = executeSql!("DROP TABLE IF EXISTS ${names.intRangeTable};");
        let* _  = executeSql!(classDescriptionTableDdl(names.classDescriptionTable));
        let* _  = executeSql!(characteristicTableDdl(names.characteristicTable));
        let* _  = executeSql!(picklistValueTableDdl(names.picklistValueTable));
        let* _  = executeSql!(intRangeTableDdl(names.intRangeTable));
        let* _  = commit!();
        point()


    pub def storeClassListData(names: ClassListTableNames, src: ClassRecords): DbMonad[r, Unit, Int32] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point};
        let* n1 = storeClassDescriptions(names.classDescriptionTable, src.classDescriptions);
        let* n2 = storeCharacteristics(names.characteristicTable, src.characteristics);
        let* n3 = storePicklistValues(names.picklistValueTable, src.picklistValues);
        let* n4 = storeIntRanges(names.intRangeTable, src.intRanges);
        point(n1 + n2 + n3 + n4)
    



    // # ClassDescription
    def storeClassDescriptions(table: String, rows: List[ClassDescription]): DbMonad[r, Unit, Int32] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, liftAction};
        store({tableName = table, prepStatement = insertClassDescriptionRowSql(table), setter = x -> classDescriptionSetter(x) as \ Write(r)}, rows)

    def classDescriptionSetter(x: ClassDescription): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!, putInt32At!, putOptionInt32At!};
        putStringAt!(0, x.className) *> putStringAt!(1, x.description) 

    def classDescriptionTableDdl(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ( "
                :: "class_name TEXT NOT NULL, "
                :: "description TEXT NOT NULL, "
                :: "PRIMARY KEY(class_name) "
                :: ");"
                :: Nil
        )

    def insertClassDescriptionRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(class_name, "
                :: "description) "
                :: "VALUES(?,?);"
                :: Nil
        )

    // # Characteristic
    
    def storeCharacteristics(table: String, rows: List[Characteristic]): DbMonad[r, Unit, Int32] \ {IO, Write(r)}=
        use BasicDb/DbMonad.{flatMap, liftAction};
        store({tableName = table, prepStatement = insertCharacteristicRowSql(table), setter = x -> characteristicSetter(x) as \ Write(r)}, rows)

    def characteristicSetter(x: Characteristic): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!, putInt32At!, putOptionInt32At!};
        putStringAt!(0, x.className)
            *> putStringAt!(1, x.charName) 
            *> putStringAt!(2, x.description) 
            *> putStringAt!(3, x.s4Datatype) 
            *> putInt32At!(4, x.textLength) 
            *> putOptionInt32At!(5, x.decimalPlaces)

        
    def characteristicTableDdl(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ( "
                :: "class_name TEXT NOT NULL, "
                :: "char_name TEXT NOT NULL, "
                :: "description TEXT NOT NULL, "
                :: "char_data_type TEXT NOT NULL, "
                :: "data_length INTEGER NOT NULL, "
                :: "decimal_places INTEGER, "
                :: "PRIMARY KEY(class_name, char_name) "
                :: ");"
                :: Nil
        )

    def insertCharacteristicRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(class_name, "
                :: "char_name, "
                :: "description, "
                :: "char_data_type, "
                :: "data_length, "
                :: "decimal_places) "
                :: "VALUES(?,?,?, ?,?,?);"
                :: Nil
        )

    // # PicklistValue
    def storePicklistValues(table: String, rows: List[PicklistValue]): DbMonad[r, Unit, Int32] \ {IO, Write(r)}  =
        use BasicDb/DbMonad.{flatMap, liftAction};
        store({tableName = table, prepStatement = insertPicklistValueRowSql(table), setter = x -> picklistValueSetter(x) as \ Write(r)}, rows)

    def picklistValueSetter(x: PicklistValue): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!};
        putStringAt!(0, x.className)
            *> putStringAt!(1, x.charName) 
            *> putStringAt!(2, x.value) 

        
    def picklistValueTableDdl(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ( "
                :: "class_name TEXT NOT NULL, "
                :: "char_name TEXT NOT NULL, "
                :: "value TEXT NOT NULL, "
                :: "PRIMARY KEY(class_name, char_name, value) "
                :: ");"
                :: Nil
        )

    def insertPicklistValueRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(class_name, "
                :: "char_name, "
                :: "value) "
                :: "VALUES(?,?,?);"
                :: Nil
        )

    // # IntRange
    def storeIntRanges(table: String, rows: List[IntRange]): DbMonad[r, Unit, Int32] \ {IO, Write(r)} =
        store({tableName = table, prepStatement = insertIntRangeRowSql(table), setter = x -> intRangeSetter(x) as \ Write(r)}, rows)

    // def intRangeSetter1(): Setter[r, Unit, IntRange] = x -> intRangeSetter(x)

    def intRangeSetter(x: IntRange): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!, putInt32At!};
        putStringAt!(0, x.className)
            *> putStringAt!(1, x.charName) 
            *> putInt32At!(2, x.rangeFrom)
            *> putInt32At!(3, x.rangeTo)

    // No primary key
    def intRangeTableDdl(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ( "
                :: "class_name TEXT NOT NULL, "
                :: "char_name TEXT NOT NULL, "
                :: "range_from INTEGER NOT NULL, "
                :: "range_to INTEGER NOT NULL "
                :: ");"
                :: Nil
        )

    def insertIntRangeRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(class_name, "
                :: "char_name, "
                :: "range_from, "
                :: "range_to) "
                :: "VALUES(?,?,?, ?);"
                :: Nil
        )


    // Helpers

    type alias Setter[r: Region, ka: Type, a: Type] = a -> PreparedStatementSetter[r, ka, ka]

    def store(config: {tableName :: String, 
                        prepStatement :: String, 
                        setter :: Setter[r, ka, a]}, rows: t[a]): DbMonad[r, ka, Int32] \ {IO, Write(r)} with Foldable[t] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit!, executeSql!, prepareStatement!, psExecuteUpdate!, commit!};
        let* _          = setAutoCommit!(false);
        let* _          = executeSql!("DELETE FROM ${config.tableName};");
        let* stmt       = prepareStatement!(config.prepStatement);
        let psSetter    = config.setter;
        let* nrows      = Foldable.foldLeftM((ac, x) -> 
                                {let* n = psExecuteUpdate!(stmt, psSetter(x)); point(ac+n)}, 0, rows);
        let* _          = commit!();
        point(nrows)


}
