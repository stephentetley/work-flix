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

namespace PDTKit/Aggregate/Loader {

    use Functor.{<$>};
    use Applicative.{<*>};
    
    use BasicDb.DbMonad;
    use BasicDb.RowEvaluator;

    use PDTKit/Aggregate/Schema.{Classification, ValueRow};

    pub def readAll(src: System.FilePath): Result[#{Classification, ValueRow | r}, String] & Impure = 
        BasicDb/DbMonad.runSQLite(readAllDb(), src)


    pub def readAllDb(): DbMonad[#{Classification, ValueRow | r}] = 
        ((x1, x2) -> x1 <+> x2)
            <$> readClassifications()
            <*> readValueRows()
        

    def readClassifications(): DbMonad[#{Classification | r}] = 
        let sql = String.unlines(
                    "SELECT pahm.source_file,  pahm.adt_heading_value " 
                        :: "FROM pdt_adt_header_metadata pahm "
                        :: "WHERE pahm.adt_heading_name = 'Classification Title'; "
                        :: Nil
        );
        BasicDb/Reader.allRelations(evalClassification(), sql)


    def evalClassification(): RowEvaluator[#{Classification | r}] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2) -> #{ Classification(x1, x2). })
            <$> getStringAt(0)  
            <*> getStringAt(1)

    def readValueRows(): DbMonad[#{ValueRow | r}] = 
        let sql = String.unlines(
                    "SELECT prv.asset_name, prv.source_file, prv.field_name, prv.field_value "
                        :: "FROM pdt_raw_values prv "
                        :: "WHERE prv.field_name <> 'Asset Name';"
                        :: Nil
        );
        BasicDb/Reader.allRelations(evalValueRow(), sql)


    def evalValueRow(): RowEvaluator[#{ValueRow | r}] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2, x3, x4) -> #{ ValueRow(x1, x2, x3, x4). })
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)
            <*> getStringAt(3)


}
