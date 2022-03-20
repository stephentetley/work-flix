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

namespace S4Loader/PDT/BuildDb/MakeProperties {

    use Functor.{<$>};
    use Applicative.{<*>};

    use BasicDb.DbMonad;
    use BasicDb.RowEvaluator;

    use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, DateProperty};
    use S4Loader/PDT/BuildDb/Schema.{PDTRawValue, FieldType};

    /// Reads from another SQLite db...
    pub def readPDTRawValues(path: {pathToPdtDb :: System.FilePath}, viewName: String): DbMonad[#{PDTRawValue| r}] = 
        let sql = "SELECT item_name, pdt_class_name, field_name, field_value FROM ${viewName} ORDER BY item_name;";
        BasicDb/DbMonad.localSQLiteConnection(path.pathToPdtDb, BasicDb/Reader.allRelations(evalPDTRawValue(), sql))

    def evalPDTRawValue(): RowEvaluator[#{PDTRawValue | r}] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2, x3, x4) -> #{ PDTRawValue(x1, x2, x3, x4). })
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)
            <*> getStringAt(3)

    ///TODO expand with field evaluators
    pub def genProperties(input: #{PDTRawValue, FieldType | r}): #{StringProperty, IntProperty, FloatProperty, DateProperty | r} = 
        let rules = #{
            
            StringProperty(uid, propName, propValue) :- 
                PDTRawValue(uid, _, propName, propValue),
                FieldType(propName, "String").

            IntProperty(uid, propName, S4Loader/Base/Utils.intValue(propValue)) :-
                PDTRawValue(uid, _, propName, propValue),
                FieldType(propName, "Int"),
                if S4Loader/Base/Utils.isIntValue(propValue).

            FloatProperty(uid, propName, S4Loader/Base/Utils.floatValue(propValue)) :-
                PDTRawValue(uid, _, propName, propValue),
                FieldType(propName, "Float"),
                if S4Loader/Base/Utils.isFloatValue(propValue).

            DateProperty(uid, propName, S4Loader/Base/Utils.dateFromIsoLocalDateTime(propValue)) :- 
                PDTRawValue(uid, _, propName, propValue),
                FieldType(propName, "Date"),
                if S4Loader/Base/Utils.isIsoLocalDateTimeValue(propValue).

        };
        let input1 = input as #{PDTRawValue, FieldType, StringProperty, IntProperty, FloatProperty, DateProperty | r};
        solve (input1 <+> rules) project StringProperty, IntProperty, FloatProperty, DateProperty



}
