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

namespace AutoLifting/SetupDb/TypeMapping {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;

    use AutoLifting/Common/Datatypes.{FixedOrPortable};
    use AutoLifting/Common/Datatypes.FixedOrPortable.{Fixed, Portable};
    

    /// Build Type Mapping Table...

    type alias TypeMappingRow = 
        { aibEquipmentType: String
        , nameContains: Option[String]        /// Regex pattern?
        , category: String
        , s4ObjectType: String
        , s4ObjectClass: String
        , fixedOrPortable: String
        }

    pub def storeTypeMapping(tableName: String, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{return, flatMap, liftActionResult, map};
        let* xs     = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readTypeMappingTable(), src));
        let* _      = exportTypeMappingRows(tableName, xs);
        return()
        

    def readTypeMappingTable(): SheetReader[List[TypeMappingRow]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};      
        let* s1     = getSheetNamed("AI2_to_EquiClass");
        let* xs     = allNamedRows(s1, evalTypeMappingRow());
        return(xs)


    // AI2 Equi Type, Name Contains, Category, Object Type, Classification, S4 Description (in classes export Pdf), Fixed or Portable
    def evalTypeMappingRow(): NamedRowEvaluator[TypeMappingRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getStringNamed, getStringNamedWithDefault};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((s1, s2, s3, s4, s5, s6) -> 
                { aibEquipmentType  = s1
                , nameContains      = s2
                , category          = s3
                , s4ObjectType      = s4
                , s4ObjectClass     = s5
                , fixedOrPortable   = s6
                })
            <&> getStringNamed("AI2 Equi Type")
            <*> optional(getStringNamed("Name Contains"))
            <*> getStringNamed("Category")
            <*> getStringNamed("Object Type")
            <*> getStringNamed("Classification")
            <*> getStringNamed("Fixed or Portable")

    /// Always drop table (fresh new data)
    def exportTypeMappingRows(tableName: String, rows: List[TypeMappingRow]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(createTableSql(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (equi_type, name_contains, category, object_type, object_class, fixed_or_portable) VALUES(?,?,?, ?,?,?);");
        let* nrows      = foldM((ac, x) -> { let* n = psExecuteUpdate(stmt, typeMappingRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A setter for MappingTableRow
    def typeMappingRowSetter(x: TypeMappingRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putOptionStringAt!};
        let* _ = putStringAt!(0, x.aibEquipmentType);
        let* _ = putOptionStringAt!(1, x.nameContains);
        let* _ = putStringAt!(2, x.category);
        let* _ = putStringAt!(3, x.s4ObjectType);
        let* _ = putStringAt!(4, x.s4ObjectClass);
        let* _ = putStringAt!(5, x.fixedOrPortable);
        return()


    def createTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "equi_type           TEXT NOT NULL,"
                :: "name_contains       TEXT"       /// Null => None
                :: "category            TEXT NOT NULL,"
                :: "object_type         TEXT NOT NULL,"
                :: "object_class        TEXT NOT NULL,"
                :: "fixed_or_portable   TEXT NOT NULL"
                :: ")"
                :: Nil
        )

}
