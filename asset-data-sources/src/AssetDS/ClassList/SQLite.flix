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


namespace AssetDS/ClassList/SQLite {

    use Applicative.{*>};

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetDS/ClassList/Datatypes.{ClassRecords, ClassDescription, Characteristic, PicklistValue, IntRange};




    pub def createTables(): DbMonad[r, ka, Unit] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit!, executeSql!, commit!};
        let* _  = setAutoCommit!(false);
        let* _  = executeSql!("DROP TABLE IF EXISTS classlist_classes;");
        let* _  = executeSql!("DROP TABLE IF EXISTS classlist_characteristics;");
        let* _  = executeSql!("DROP TABLE IF EXISTS classlist_picklist_values;");
        let* _  = executeSql!("DROP TABLE IF EXISTS classlist_int_ranges;");
        let* _  = executeSql!(classDescriptionTableDdl());
        let* _  = executeSql!(characteristicTableDdl());
        let* _  = executeSql!(picklistValueTableDdl());
        let* _  = executeSql!(intRangeTableDdl());
        let* _  = commit!();
        point()


    pub def storeClassListData(src: ClassRecords): DbMonad[r, Unit, Int32] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point};
        let* n1 = storeClassDescriptions(src.classDescriptions);
        let* n2 = storeCharacteristics(src.characteristics);
        let* n3 = storePicklistValues(src.picklistValues);
        let* n4 = storeIntRanges(src.intRanges);
        point(n1 + n2 + n3 + n4)
    



    // # ClassDescription
    def storeClassDescriptions(rows: List[ClassDescription]): DbMonad[r, Unit, Int32] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, liftAction};
        store({prepStatement = insertClassDescriptionRowSql(), setter = x -> classDescriptionSetter(x) as \ Write(r)}, rows)

    def classDescriptionSetter(x: ClassDescription): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!, putInt32At!, putOptionInt32At!};
        putStringAt!(0, x.className) 
            *> putStringAt!(1, x.classType) 
            *> putStringAt!(2, x.description) 

    def classDescriptionTableDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS classlist_classes ( "
                :: "class_name TEXT NOT NULL, "
                :: "class_type TEXT NOT NULL, "
                :: "description TEXT NOT NULL, "
                :: "PRIMARY KEY(class_name, class_type) "
                :: ");"
                :: Nil
        )

    def insertClassDescriptionRowSql(): String =
        String.unwords(
            "INSERT OR IGNORE INTO classlist_classes "
                :: "(class_name, "
                :: "class_type,"
                :: "description) "
                :: "VALUES(?,?,?);"
                :: Nil
        )

    // # Characteristic
    
    def storeCharacteristics(rows: List[Characteristic]): DbMonad[r, Unit, Int32] \ {IO, Write(r)}=
        use BasicDb/DbMonad.{flatMap, liftAction};
        store({prepStatement = insertCharacteristicRowSql(), setter = x -> characteristicSetter(x) as \ Write(r)}, rows)

    def characteristicSetter(x: Characteristic): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!, putInt32At!, putOptionInt32At!};
        putStringAt!(0, x.className)
            *> putStringAt!(1, x.classType) 
            *> putStringAt!(2, x.charName) 
            *> putStringAt!(3, x.description) 
            *> putStringAt!(4, x.s4Datatype) 
            *> putInt32At!(5, x.textLength) 
            *> putOptionInt32At!(6, x.decimalPlaces)

        
    def characteristicTableDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS classlist_characteristics ( "
                :: "class_name TEXT NOT NULL, "
                :: "class_type TEXT NOT NULL, "
                :: "char_name TEXT NOT NULL, "
                :: "description TEXT NOT NULL, "
                :: "char_data_type TEXT NOT NULL, "
                :: "data_length INTEGER NOT NULL, "
                :: "decimal_places INTEGER, "
                :: "PRIMARY KEY(class_name, class_type, char_name) "
                :: ");"
                :: Nil
        )

    def insertCharacteristicRowSql(): String =
        String.unwords(
            "INSERT OR IGNORE INTO classlist_characteristics "
                :: "(class_name, "
                :: "class_type, "
                :: "char_name, "
                :: "description, "
                :: "char_data_type, "
                :: "data_length, "
                :: "decimal_places) "
                :: "VALUES(?,?,?, ?,?,?, ?);"
                :: Nil
        )

    // # PicklistValue
    def storePicklistValues(rows: List[PicklistValue]): DbMonad[r, Unit, Int32] \ {IO, Write(r)}  =
        use BasicDb/DbMonad.{flatMap, liftAction};
        store({prepStatement = insertPicklistValueRowSql(), setter = x -> picklistValueSetter(x) as \ Write(r)}, rows)

    def picklistValueSetter(x: PicklistValue): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!};
        putStringAt!(0, x.className)
            *> putStringAt!(1, x.classType) 
            *> putStringAt!(2, x.charName) 
            *> putStringAt!(3, x.value) 

        
    def picklistValueTableDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS classlist_picklist_values ( "
                :: "class_name TEXT NOT NULL, "
                :: "class_type TEXT NOT NULL, "
                :: "char_name TEXT NOT NULL, "
                :: "value TEXT NOT NULL, "
                :: "PRIMARY KEY(class_name, class_type, char_name, value) "
                :: ");"
                :: Nil
        )

    def insertPicklistValueRowSql(): String =
        String.unwords(
            "INSERT OR IGNORE INTO classlist_picklist_values "
                :: "(class_name, "
                :: "class_type, "
                :: "char_name, "
                :: "value) "
                :: "VALUES(?,?,?, ?);"
                :: Nil
        )

    // # IntRange
    def storeIntRanges(rows: List[IntRange]): DbMonad[r, Unit, Int32] \ {IO, Write(r)} =
        store({prepStatement = insertIntRangeRowSql(), setter = x -> intRangeSetter(x) as \ Write(r)}, rows)

    
    def intRangeSetter(x: IntRange): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!, putInt32At!};
        putStringAt!(0, x.className)
            *> putStringAt!(1, x.classType)
            *> putStringAt!(2, x.charName) 
            *> putInt32At!(3, x.rangeFrom)
            *> putInt32At!(4, x.rangeTo)

    def intRangeTableDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS classlist_int_ranges ( "
                :: "class_name TEXT NOT NULL, "
                :: "class_type TEXT NOT NULL, "
                :: "char_name TEXT NOT NULL, "
                :: "range_from INTEGER NOT NULL, "
                :: "range_to INTEGER NOT NULL, "
                :: "PRIMARY KEY(class_name, class_type, char_name) "
                :: ");"
                :: Nil
        )

    def insertIntRangeRowSql(): String =
        String.unwords(
            "INSERT OR IGNORE INTO classlist_int_ranges "
                :: "(class_name, "
                :: "class_type, "
                :: "char_name, "
                :: "range_from, "
                :: "range_to) "
                :: "VALUES(?,?,?, ?,?);"
                :: Nil
        )


    // Helpers

    type alias Setter[r: Region, ka: Type, a: Type] = a -> PreparedStatementSetter[r, ka, ka]

    def store(config: {prepStatement :: String, 
                        setter :: Setter[r, ka, a]}, rows: t[a]): DbMonad[r, ka, Int32] \ {IO, Write(r)} with Foldable[t] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit!, prepareStatement!, psExecuteUpdate!, commit!};
        let* _          = setAutoCommit!(false);
        let* stmt       = prepareStatement!(config.prepStatement);
        let psSetter    = config.setter;
        let* nrows      = Foldable.foldLeftM((ac, x) -> 
                                {let* n = psExecuteUpdate!(stmt, psSetter(x)); point(ac+n)}, 0, rows);
        let* _          = commit!();
        point(nrows)


}
