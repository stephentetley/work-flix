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

namespace PDTKit/Configuration/ReadFieldEvalSpecXlsx {

    use Functor.{<$>};
    use Applicative.{<*>};

    use Basis/System.FilePath;

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.NamedRowEvaluator;


    /// ## pdt_field_eval_specifications.xlsx



    pub type alias FieldEvalRow = 
        { pdtAssetClass :: String            // e.g. "PDT_Damper"
        , pdtFieldName :: String
        , s4Type :: String
        , evaluatorType :: String
        , evaluator :: String
        , builtinArg1 :: String                // e.g. "kg"
        , sample :: String
        }

    pub def readAndStoreFieldEvalSpecs(src: FilePath): DbMonad[List[FieldEvalRow]] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> readFieldEvals(src));
        let* _      = insertPdtFieldEvaluators(ans);
        point(ans)

    def readFieldEvals(src: FilePath): Result[List[FieldEvalRow], String] & Impure = 
        use Result.flatMap;
        use SheetIO/NamedRowEvaluator.{optional};
        let* tabs = SheetIO/SheetReader.runXlsx(SheetIO/SheetReader.getSheetNames(), src);
        let* ans  = SheetIO/Reader.someNamedRowsOfSheets(optional(evalFieldEvalRow()), tabs, src);
        Ok(ans)

    /// Drop incomplete rows - caller should wrap this with `optional`
    def evalFieldEvalRow(): NamedRowEvaluator[FieldEvalRow] = 
        use SheetIO/NamedRowEvaluator.{getSheetName, getNonEmptyContentNamed, getTrimmedContentNamed}; 
        ((x1, x2, x3, x4, x5, x6, x7) ->  
                { pdtAssetClass = x1, pdtFieldName = x2, s4Type = x3, 
                  evaluatorType = x4, evaluator = String.toLowerCase(x5), builtinArg1 = x6, sample = x7})
            <$> getSheetName()
            <*> getNonEmptyContentNamed("pdt_field_name") 
            <*> getNonEmptyContentNamed("s4_type") 
            <*> getNonEmptyContentNamed("evaluator_type")
            <*> getTrimmedContentNamed("evaluator")            
            <*> getTrimmedContentNamed("builtin_arg1")
            <*> getTrimmedContentNamed("sample")


    def insertPdtFieldEvaluators(src: List[FieldEvalRow]): DbMonad[Int32] = 
        let sqlstrings = { 
            prepStmt = String.unlines(
                            "INSERT OR IGNORE INTO meta_pdt_field_evaluators"
                        :: "(pdt_asset_class, pdt_field_name, s4_type, eval_type, evaluator, builtin_arg1, sample)"
                        :: "VALUES(?,?,?, ?,?,?, ?);"
                        :: Nil),
            tableActions = "DELETE FROM meta_pdt_field_evaluators;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, fieldEvaluatorsSetter, src)
    

    def fieldEvaluatorsSetter(x: FieldEvalRow): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!};
        let* _  = putStringAt!(0, x.pdtAssetClass);
        let* _  = putStringAt!(1, x.pdtFieldName);
        let* _  = putStringAt!(2, x.s4Type);
        let* _  = putStringAt!(3, x.evaluatorType);
        let* _  = putStringAt!(4, x.evaluator);
        let* _  = putStringAt!(5, x.builtinArg1);
        let* _  = putStringAt!(6, x.sample);
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
                :: "pdt_asset_class TEXT NOT NULL,"
                :: "pdt_field_name TEXT NOT NULL,"
                :: "s4_type TEXT NOT NULL,"
                :: "eval_type TEXT NOT NULL,"
                :: "evaluator TEXT,"
                :: "builtin_arg1 TEXT,"
                :: "sample TEXT,"
	            :: "PRIMARY KEY(pdt_asset_class, pdt_field_name)"
	            :: ");"
                :: Nil
        )

}
