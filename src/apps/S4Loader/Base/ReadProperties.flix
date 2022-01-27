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

namespace S4Loader/Base/ReadProperties {


    use Functor.{<$>};
    use Applicative.{<*>};

    use BasicDb.DbMonad;
    use BasicDb.RowEvaluator;

    use S4Loader/Base/Relations.{StringProperty, IntProperty, FloatProperty, DateProperty,
        PropertyAlias, AibProperties};


    pub type alias DbRelations[r1: SchemaRow] =
        #{StringProperty, IntProperty, FloatProperty, PropertyAlias | r1}

    pub def loadDbRelations(dbpath: System.FilePath): Result[DbRelations[r1], String] & Impure =         
        let loadAll = () -> { 
            ((r1, r2) -> r1 <+> r2 )
                <$> readProperties()
                <*> readPropertyAliases()
        };
        BasicDb/DbMonad.runSQLite(loadAll(), dbpath)



    /// # Properties



    pub def readProperties(): DbMonad[AibProperties[r1]] =
        ((r1, r2, r3, r4) -> r1 <+> r2 <+> r3 <+> r4)
            <$> readPropertyTable("string_properties",  evalStringProperty())
            <*> readPropertyTable("int_properties",     evalIntProperty())
            <*> readPropertyTable("float_properties",   evalFloatProperty())
            <*> readPropertyTable("date_properties",    evalDateProperty())
        

    def readPropertyTable(tableName: String, eval: RowEvaluator[#{| r}]): DbMonad[#{| r}] = 
        let sql = "SELECT equipment_id, prop_name, prop_value FROM ${tableName} ORDER BY equipment_id;";
        BasicDb/Reader.allRelations(eval, sql)


    def evalStringProperty(): RowEvaluator[#{StringProperty | r}] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2, x3) -> #{ StringProperty(x1, x2, x3). })
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)

    def evalIntProperty(): RowEvaluator[#{IntProperty | r}] = 
        use BasicDb/RowEvaluator.{getStringAt, getInt32At};
        ((x1, x2, x3) -> #{IntProperty(x1, x2, x3).})
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getInt32At(2)

    def evalFloatProperty(): RowEvaluator[#{FloatProperty | r}] = 
        use BasicDb/RowEvaluator.{getStringAt, getFloat64At};
        ((x1, x2, x3) -> #{FloatProperty(x1, x2, x3).})
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getFloat64At(2)

    def evalDateProperty(): RowEvaluator[#{DateProperty | r}] = 
        use BasicDb/RowEvaluator.{getStringAt, getLocalDateStringAt};
        ((x1, x2, x3) -> #{DateProperty(x1, x2, x3).})
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getLocalDateStringAt(2)

    /// # Meta data - property aliases

    /// TODO - remove and use data derived from Class List

    pub def readPropertyAliases(): DbMonad[#{PropertyAlias |r1}] =         
        let sql = "SELECT ai_prop_name, s4_class_name, s4_char_name FROM dd_property_aliases ORDER BY ai_prop_name;";
        BasicDb/Reader.allRelations(evalPropertyAlias(), sql)

    
    def evalPropertyAlias(): RowEvaluator[#{PropertyAlias | r}] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2, x3) -> #{PropertyAlias(x1, x2, x3).})
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)

}
