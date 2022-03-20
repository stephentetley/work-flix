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

// Multiple tabs

namespace PDTKit/Configuration/ReadFieldEvalXlsx {

    use Functor.{<$>};
    use Applicative.{<*>};

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.NamedRowEvaluator;


    /// ## s4_to_pdt_one_to_one_mappings.csv



    pub type alias FieldEvalRow = 
        { pdtClass :: String            // e.g. "PDT_Damper"
        , pdtFieldName :: String
        , s4Type :: String
        , evaluatorType :: String
        , evaluator :: String
        , sample :: String
        }

    pub def readAndStoreFieldEvals(src: System.FilePath): DbMonad[List[FieldEvalRow]] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> readFieldEvals(src));
        let* _      = insertOtoMappings(ans);
        point(ans)

    def readFieldEvals(src: System.FilePath): Result[List[FieldEvalRow], String] & Impure = 
        use Result.flatMap;
        use SheetIO/NamedRowEvaluator.{optional};
        let* tabs = SheetIO/SheetReader.runXlsx(SheetIO/SheetReader.getSheetNames(), src);
        let* ans  = SheetIO/Reader.someNamedRowsOfSheets(optional(evalFieldEvalRow()), tabs, src);
        Ok(ans)

    /// Drop incomplete rows - wrap this with `optional`
    def evalFieldEvalRow(): NamedRowEvaluator[FieldEvalRow] = 
        use SheetIO/NamedRowEvaluator.{getSheetName, getNonEmptyContentNamed, getTrimmedContentNamed}; 
        ((x1, x2, x3, x4, x5, x6) ->  
                {pdtClass = x1, pdtFieldName = x2, s4Type = x3, evaluatorType = x4, evaluator = x5, sample = x6})
            <$> getSheetName()
            <*> getNonEmptyContentNamed("pdt_field_name ") 
            <*> getNonEmptyContentNamed("s4_type") 
            <*> getNonEmptyContentNamed("evaluator_type")
            <*> getTrimmedContentNamed("evaluator")
            <*> getTrimmedContentNamed("sample")


    def insertOtoMappings(src: List[FieldEvalRow]): DbMonad[Int32] = 
        let sqlstrings = { 
            prepStmt = String.unlines(
                            "INSERT OR IGNORE INTO meta_pdt_field_evaluators"
                        :: "(pdt_class_name, pdt_field_name, s4_type, eval_type, evaluator, sample)"
                        :: "VALUES(?,?,?, ?,?,?);"
                        :: Nil),
            tableActions = "DELETE FROM meta_pdt_field_evaluators;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, fieldEvaluatorsSetter, src)
    

    def fieldEvaluatorsSetter(x: FieldEvalRow): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!};
        let* _  = putStringAt!(0, x.pdtClass);
        let* _  = putStringAt!(1, x.pdtFieldName);
        let* _  = putStringAt!(2, x.s4Type);
        let* _  = putStringAt!(3, x.evaluatorType);
        let* _  = putStringAt!(4, x.evaluator);
        let* _  = putStringAt!(5, x.sample);
        point()

    pub def createMetaPdtFieldEvaluatorsTable(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP TABLE IF EXISTS meta_pdt_field_evaluators;");
        let* _  = execute(metaPdtFieldEvaluatorsTableDdl());
        let* _  = commit();
        point()


    def metaPdtFieldEvaluatorsTableDdl(): String =
        String.unlines(
            "CREATE TABLE IF NOT EXISTS meta_pdt_field_evaluators ("
                :: "pdt_class_name TEXT NOT NULL,"
                :: "pdt_field_name TEXT NOT NULL,"
                :: "s4_type TEXT NOT NULL,"
                :: "eval_type TEXT NOT NULL,"
                :: "evaluator TEXT,"
                :: "sample TEXT,"
	            :: "PRIMARY KEY(pdt_class_name, pdt_field_name)"
	            :: ");"
                :: Nil
        )

}
