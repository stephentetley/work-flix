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

namespace S4Loader/PDT/Gen/ReadDb {

    use Functor.{<$>};
    use Applicative.{<*>};
    
    use BasicDb.DbMonad;
    use BasicDb.RowEvaluator;

    use S4Loader/Base/Schema.{PropertyAlias, StringProperty, IntProperty, FloatProperty, DateProperty};

    pub type alias PersistentRelations[r1: SchemaRow] =
        #{PropertyAlias, StringProperty, IntProperty, FloatProperty, DateProperty | r1}    

    pub def readDbAll(): DbMonad[PersistentRelations[r]] = 
        use BasicDb/DbMonad.{flatMap, point};
        let* r1     = readPropertyAliases();
        let* r2     = S4Loader/Base/ReadProperties.readProperties();
        point(r1 <+> r2)

    pub def readPropertyAliases(): DbMonad[#{PropertyAlias | r}] = 
        let sql = "SELECT mec.description, mec.class_name, mec.char_name FROM meta_equi_characteristics mec;";
        BasicDb/Reader.allRelations(evalPropertyAlias(), sql)


    def evalPropertyAlias(): RowEvaluator[#{PropertyAlias | r}] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2, x3) -> #{ PropertyAlias(x1, x2, x3). })
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)

}
