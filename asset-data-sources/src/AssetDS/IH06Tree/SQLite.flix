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

namespace AssetDS/IH06Tree/SQLite {

    use Applicative.{point, *>};

    use Basis/NIO/File.Path;

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;


    use AssetDS/IH06Tree/Datatypes.{IH06File, IH06Row, FlocRow, EquiRow};
    use AssetDS/IH06Tree/Datatypes.IH06Row.{FlocRow, EquiRow};

    pub type alias IH06TableNames = 
        { flocTable :: String
        , equiTable :: String
        }

    pub def exportSQLite(names: IH06TableNames, path: Path, src: IH06File): Result[Unit, String] \ IO = region r {
        let action = createIH06Tables(names) *> storeIH06Data(names, src) *> point();
        BasicDb/DbMonad.runSQLite(r, action, path)
    }

    pub def createIH06Tables(names: IH06TableNames): DbMonad[r, Unit, Unit] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, setAutoCommit!, executeSql!, commit!};
        let* _  = setAutoCommit!(false);
        let* _  = executeSql!("DROP TABLE IF EXISTS ${names.flocTable};");
        let* _  = executeSql!("DROP TABLE IF EXISTS ${names.equiTable};");
        let* _  = executeSql!(flocTableDdl(names.flocTable));
        let* _  = executeSql!(equiTableDdl(names.equiTable));
        let* _  = commit!();
        point()

    pub def storeIH06Data(names: IH06TableNames, src: IH06File): DbMonad[r, Unit, Int32] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap};
        let flocRows    = List.filterMap(getFlocRow, src.rows);
        let equiRows    = List.filterMap(getEquiRow, src.rows);
        let* n1         = storeFlocRows(names.flocTable, flocRows);
        let* n2         = storeEquiRows(names.equiTable, equiRows);
        point(n1 + n2)

    def getFlocRow(x: IH06Row): Option[FlocRow] = match x {
        case FlocRow(x1) => Some(x1)
        case _           => None
    }

    def getEquiRow(x: IH06Row): Option[EquiRow] = match x {
        case EquiRow(x1) => Some(x1)
        case _           => None
    }



    def storeFlocRows(table: String, rows: t[FlocRow]): DbMonad[r, Unit, Int32] \ {IO, Write(r)} with Foldable[t] =
        let sqlstrings = { 
            prepStmt = insertFlocRowSql(table),
            tableActions = "DELETE FROM ${table};" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, flocRowSetter, rows)


    def flocRowSetter(x: FlocRow): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!, putOptionStringAt!};
        let parent = if (x.parent == "") None else Some(x.parent);
        putStringAt!(0, x.floc) 
            *> putStringAt!(1, x.description) 
            *> putOptionStringAt!(2, parent)


    def insertFlocRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(floc, "
                :: "description, "
                :: "parent) "
                :: "VALUES(?,?,?);"
                :: Nil
        )

    def flocTableDdl(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ( "
                :: "floc TEXT NOT NULL, "
                :: "description TEXT NOT NULL, "
                :: "parent TEXT, "
                :: "PRIMARY KEY(floc) "
                :: ");"
                :: Nil
        )        

    def storeEquiRows(table: String, rows: t[EquiRow]): DbMonad[r, Unit, Int32] \ {IO, Write(r)} with Foldable[t] =
        let sqlstrings = { 
            prepStmt = insertEquiRowSql(table),
            tableActions = "DELETE FROM ${table};" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, equiRowSetter, rows)


    def equiRowSetter(x: EquiRow): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!, putOptionStringAt!};
        let superordinate = if (x.superordinate == "") None else Some(x.superordinate);
        putStringAt!(0, x.equiId) 
            *> putStringAt!(1, x.description) 
            *> putStringAt!(2, x.floc) 
            *> putOptionStringAt!(3, superordinate)


    def insertEquiRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(equiId, "
                :: "description, "
                :: "floc, "
                :: "superordinate) "
                :: "VALUES(?,?,?, ?);"
                :: Nil
        )

    def equiTableDdl(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ( "
                :: "equiId TEXT NOT NULL, "
                :: "description TEXT NOT NULL, "
                :: "floc TEXT NOT NULL,"
                :: "superordinate TEXT,"
                :: "PRIMARY KEY(equiId) "
                :: ");"
                :: Nil
        )      

}
