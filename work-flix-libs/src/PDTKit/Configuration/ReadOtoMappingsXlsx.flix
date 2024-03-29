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

// One-to-One mappings - multiple tabs

namespace PDTKit/Configuration/ReadOtoMappingsXlsx {

    use Functor.{<$>};
    use Applicative.{<*>};

    use Basis/System.FilePath;

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.NamedRowEvaluator;


    /// s4_to_pdt_one_to_one_mapping.xlsx

    /// Ideally we wouldn't use an xslx file but curating multiple Csv files
    /// is too cumbersome...

    pub type alias OtoMappingRow = 
        { s4EquiClass :: String 
        , s4EquiChar :: String
        , pdtFieldName :: String
        }

    pub def readAndStoreOtoMappings(src: FilePath): DbMonad[List[OtoMappingRow]] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> readOtoMappings(src));
        let* _      = insertOtoMappings(ans);
        point(ans)

    /// s4_equi_class,s4_equi_char,pdt_field_name
    /// pdt_field_name maybe be blank - drop.
    def readOtoMappings(src: FilePath): Result[List[OtoMappingRow], String] & Impure = 
        use Result.flatMap;
        let* tabs = SheetIO/SheetReader.runXlsx(SheetIO/SheetReader.getSheetNames(), src);
        let* ans  = SheetIO/Reader.someNamedRowsOfSheets(evalOtoMappingRow(), tabs, src);
        Ok(ans)

    /// Drop rows with blank `pdt_field_name`
    def evalOtoMappingRow(): NamedRowEvaluator[Option[OtoMappingRow]] = 
        use SheetIO/NamedRowEvaluator.{getNonEmptyContentNamed, getTrimmedContentNamed}; 
        ((x1, x2, x3) ->  if (String.isEmpty(x3)) None else Some({s4EquiClass = x1, s4EquiChar = x2, pdtFieldName = x3}))
            <$> getNonEmptyContentNamed("s4_equi_class") 
            <*> getNonEmptyContentNamed("s4_equi_char") 
            <*> getTrimmedContentNamed("pdt_field_name")


    def insertOtoMappings(src: List[OtoMappingRow]): DbMonad[Int32] = 
        let sqlstrings = { 
            prepStmt = "INSERT OR IGNORE INTO meta_pdt_oto_mappings (s4_equi_class,s4_equi_char,pdt_field_name) VALUES(?,?,?);",
            tableActions = "DELETE FROM meta_pdt_oto_mappings;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, otoMappingSetter, src)
    

    def otoMappingSetter(x: OtoMappingRow): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!};
        let* _  = putStringAt!(0, x.s4EquiClass);
        let* _  = putStringAt!(1, x.s4EquiChar);
        let* _  = putStringAt!(2, x.pdtFieldName);
        point()

    pub def createMetaPdtOtoMappingsTable(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP TABLE IF EXISTS meta_pdt_oto_mappings;");
        let* _  = execute(metaPdtOtoMappingsTableDdl());
        let* _  = commit();
        point()


    def metaPdtOtoMappingsTableDdl(): String =
        String.unlines(
            "CREATE TABLE IF NOT EXISTS meta_pdt_oto_mappings ("
                :: "s4_equi_class TEXT NOT NULL,"
                :: "s4_equi_char TEXT NOT NULL,"
                :: "pdt_field_name TEXT NOT NULL,"
	            :: "PRIMARY KEY(s4_equi_class, s4_equi_char)"
	            :: ");"
                :: Nil
        )

}
