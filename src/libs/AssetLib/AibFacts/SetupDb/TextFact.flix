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



namespace AssetLib/AibFacts/SetupDb/TextFact {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;


    type alias TextFact = 
        { aibReference: String
        , aibFieldName: String
        , value: String
        }

    pub def createNonEmpty(reference: String, fieldName: String, value: String): Option[TextFact] = 
        if (reference != "" and fieldName != "" and value != "")
            Some({ aibReference = reference
                 , aibFieldName = fieldName
                 , value = value
                 })
        else
            None


    pub def initTextFactTable(tableName: String): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, return, execute, setAutoCommit, commit};
        let* _          = setAutoCommit(false);
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(createTableSql(tableName));
        let* _          = commit();
        return()
    

    pub def insertTextFactRows(tableName: String, rows: List[TextFact]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, setAutoCommit, prepareStatement, psExecuteUpdate, commit};
        let* _          = setAutoCommit(false);
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (aib_reference, aib_field_name, aib_field_value) VALUES(?,?,?);");
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, textFactRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    
    def textFactRowSetter(x: TextFact): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _ = putStringAt!(0, x.aibReference);
        let* _ = putStringAt!(1, x.aibFieldName);        
        let* _ = putStringAt!(2, x.value);
        return()


    def createTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "aib_reference       TEXT NOT NULL,"
                :: "aib_field_name      TEXT NOT NULL,"
                :: "aib_field_value     TEXT"
                :: ")"
                :: Nil
        )

}