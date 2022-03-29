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

namespace AssetLib/FileIO/PDT/SQLite {

    use Applicative.{*>};

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/FileIO/PDT/Datatypes.{FieldValue, ADTHeaderRow, ADTParamRow};


    pub def createPDTDatabase(srcs: List[System.FilePath], dst: System.FilePath): Result[Int32, String] & Impure = 
        let actions = 
            AssetLib/FileIO/PDT/SQLite.createPDTTables() 
                *> AssetLib/FileIO/PDT/SQLite.insertDataAll(srcs);
        BasicDb/DbMonad.runSQLite(actions, dst)


    pub def insertData(src: System.FilePath): DbMonad[Int32] =
        insertDataAll(src :: Nil)

    pub def insertDataAll(srcs: List[System.FilePath]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        use Monad.{>>=};
        let* relns  = liftActionResult(_ -> AssetLib/FileIO/PDT/Reader.readFieldValuesAll(srcs));
        let* n1     = insertFieldValues(relns);
        let* _      = deriveFileIndices();
        let* n2     = liftActionResult(_ -> AssetLib/FileIO/PDT/Reader.readADTHeaderRowsAll(srcs)) >>= insertPdtAdtHeaderRows;
        let* n3     = liftActionResult(_ -> AssetLib/FileIO/PDT/Reader.readADTParamDataAll(srcs)) >>= insertPdtAdtParamRows;
        point(n1 + n2 + n3)


    pub def createPDTTables(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP VIEW IF EXISTS pdt_values_with_item_name;");
        let* _  = execute("DROP VIEW IF EXISTS pdt_equi_items;");
        let* _  = execute("DROP TABLE IF EXISTS pdt_raw_values;");
        let* _  = execute("DROP TABLE IF EXISTS pdt_file_indices;");
        let* _  = execute("DROP TABLE IF EXISTS pdt_adt_header_metadata;");
        let* _  = execute("DROP TABLE IF EXISTS pdt_adt_param_specification;");
        let* _  = execute(pdtRawValuesTableDdl());
        let* _  = execute(pdtFileIndicesTableDdl());
        let* _  = execute(pdtAdtHeaderMetadataTableDdl());
        let* _  = execute(pdtAdtParamSpecificationTableDdl());
        let* _  = execute(pdtValuesWithShortNameViewDdl());
        let* _  = execute(pdtEquiItemsViewDdl());
        let* _  = commit();
        point()

    /// Note - this does a join in Datalog (could we do it within SQL?)
    pub def insertFieldValues(relns: #{FieldValue | r}): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, liftAction};
        let* rows = liftAction(_ -> query relns select (x1, x2, x3, x4, x5, x6, x7) from FieldValue(x1, x2, x3, x4, x5, x6, x7) |> Array.toList);
        let sqlstrings = { 
            prepStmt = insertPdtRawValuesSql(),
            tableActions = "DELETE FROM pdt_raw_values;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, pdtRawValuesSetter, rows)

    def pdtRawValuesSetter(x: (String, String, Int32, Int32, String, String, String)): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{putInt32At!, putStringAt!};
        let (x1, x2, x3, x4, x5, x6, x7) = x;
        putStringAt!(0, x1)
            *> putStringAt!(1, x2) 
            *> putInt32At!(2, x3) 
            *> putInt32At!(3, x4) 
            *> putStringAt!(4, x5) 
            *> putStringAt!(5, x6) 
            *> putStringAt!(6, x7)
        
    def insertPdtRawValuesSql(): String =
        String.unlines(
            "INSERT OR IGNORE INTO pdt_raw_values "
                :: "(source_file, "
                :: "pdt_class_name, "
                :: "row_num, "
                :: "item_num, "
                :: "asset_name, "
                :: "field_name, "
                :: "field_value) "
                :: "VALUES(?,?,?, ?,?,?, ?);"
                :: Nil
            )


        
    def pdtRawValuesTableDdl(): String =
        String.unlines(
            "CREATE TABLE IF NOT EXISTS pdt_raw_values ("
                :: "source_file TEXT NOT NULL, "
                :: "pdt_class_name TEXT NOT NULL, "
                :: "row_num INTEGER NOT NULL, "
                :: "item_num INTEGER NOT NULL, "
                :: "asset_name TEXT NOT NULL, "
                :: "field_name TEXT NOT NULL, "
                :: "field_value TEXT, "
                :: "PRIMARY KEY(source_file, item_num, asset_name, field_name)"
                :: ");"
                :: Nil
            )

    /// ADTHeaderRow

    pub def insertPdtAdtHeaderRows(rows: t[ADTHeaderRow]): DbMonad[Int32] with Foldable[t] =
        use BasicDb/DbMonad.{flatMap, liftAction};
        let sqlstrings = { 
            prepStmt = insertADTHeaderRowSql(),
            tableActions = "DELETE FROM pdt_adt_header_metadata;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, pdtADTHeaderRowSetter, rows)

    def pdtADTHeaderRowSetter(row: ADTHeaderRow): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{putInt32At!, putStringAt!};
        putStringAt!(0, row.fileName)
            *> putInt32At!(1, row.rowNumber) 
            *> putStringAt!(2, row.metaName) 
            *> putStringAt!(3, row.metaValue)
        
    def insertADTHeaderRowSql(): String =
        String.unlines(
            "INSERT OR IGNORE INTO pdt_adt_header_metadata "
                :: "(source_file, "
                :: "row_num, "
                :: "adt_heading_name, "
                :: "adt_heading_value) "
                :: "VALUES(?,?,?,?);"
                :: Nil
            )

    /// ADTParamRow
    
    pub def insertPdtAdtParamRows(rows: t[ADTParamRow]): DbMonad[Int32] with Foldable[t] =
        use BasicDb/DbMonad.{flatMap, liftAction};
        let sqlstrings = { 
            prepStmt = insertADTParamRowSql(),
            tableActions = "DELETE FROM pdt_adt_param_specification;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, pdtADTParamRowSetter, rows)

    def pdtADTParamRowSetter(row: ADTParamRow): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{putInt32At!, putStringAt!};
        putStringAt!(0, row.fileName)
            *> putInt32At!(1, row.rowNumber) 
            *> putStringAt!(2, row.category)
            *> putStringAt!(3, row.paramName)
            *> putInt32At!(4, row.paramIndex)
            *> putStringAt!(5, row.paramUnits)
            *> putStringAt!(6, row.notes)
        
    def insertADTParamRowSql(): String =
        String.unlines(
            "INSERT OR IGNORE INTO pdt_adt_param_specification "
                :: "(source_file, "
                :: "row_num, "
                :: "category, "
                :: "param_name, "
                :: "param_index, "
                :: "param_units, "
                :: "notes)"
                :: "VALUES(?,?,?, ?,?,?, ?);"
                :: Nil
            )



    def pdtAdtHeaderMetadataTableDdl(): String = 
        String.unlines(
            "CREATE TABLE IF NOT EXISTS pdt_adt_header_metadata ("
                :: "source_file         TEXT NOT NULL,"
                :: "row_num             INTEGER NOT NULL,"
                :: "adt_heading_name    TEXT NOT NULL,"
                :: "adt_heading_value   TEXT,"
                :: "PRIMARY KEY(source_file, adt_heading_name)"
                :: ");"
                :: Nil
            )

    def pdtAdtParamSpecificationTableDdl(): String = 
        String.unlines(
            "CREATE TABLE IF NOT EXISTS pdt_adt_param_specification ("
                :: "source_file TEXT NOT NULL,"
                :: "row_num INTEGER NOT NULL,"
                :: "category TEXT NOT NULL,"
                :: "param_name TEXT NOT NULL,"
                :: "param_index INTEGER NOT NULL,"
                :: "param_units TEXT,"
                :: "notes TEXT,"
                :: "PRIMARY KEY(source_file, row_num)"
                :: ");"
                :: Nil
            )

    def pdtFileIndicesTableDdl(): String = 
        String.unlines(
            "CREATE TABLE IF NOT EXISTS pdt_file_indices ("
                :: "file_index INTEGER PRIMARY KEY ASC, "
                :: "file_name TEXT NOT NULL "
                :: ");"
                :: Nil
            )

    def deriveFileIndices(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DELETE FROM pdt_file_indices;");
        let* _  = execute(insertPdtFileIndicesSql());
        let* _  = commit();
        point()

    /// Note this expects SQLite ORDER BY ... ASC to be same order as the order from the file system
    def insertPdtFileIndicesSql(): String =
        String.unlines(
            "INSERT INTO pdt_file_indices (file_name) "
                :: "SELECT DISTINCT(prv.source_file) AS file_name "
                :: "FROM pdt_raw_values prv "
                :: "ORDER BY file_name ASC;"
                :: Nil
            )

    def pdtValuesWithShortNameViewDdl(): String =
        String.unlines(
            "CREATE VIEW IF NOT EXISTS pdt_values_with_item_name(item_name, pdt_class_name, row_num, field_name, field_value) AS "
                :: "SELECT "
                :: "    printf('F%02d_C%02d_%s', pfi.file_index, prv.item_num, prv.asset_name) AS item_name, "
                :: "    prv.pdt_class_name  AS pdt_class_name, "
                :: "    prv.row_num         AS row_num, "
                :: "    prv.field_name      AS field_name, "
                :: "    prv.field_value     AS field_value "
                :: "FROM pdt_raw_values prv "
                :: "INNER JOIN pdt_file_indices pfi ON prv.source_file = pfi.file_name; "
                :: Nil
            )

    def pdtEquiItemsViewDdl(): String =
        String.unlines(
            "CREATE VIEW IF NOT EXISTS pdt_equi_items(item_name, pdt_class_name, item_type, file_index, file_name) AS "
                :: "SELECT "
                :: "printf('F%02d_C%02d_%s', pfi.file_index, prv.item_num, prv.asset_name) AS item_name, "
                :: "prv.pdt_class_name  AS pdt_class_name, "
                :: "prv.field_value     AS item_type, "
                :: "pfi.file_index      AS file_index, "
                :: "pfi.file_name       AS file_name "
                :: "FROM pdt_raw_values prv "
                :: "INNER JOIN pdt_file_indices pfi ON prv.source_file = pfi.file_name "
                :: "WHERE "
                :: "prv.field_name = 'Asset Type' "
                :: "ORDER BY item_name;"
                :: Nil
        )


}
