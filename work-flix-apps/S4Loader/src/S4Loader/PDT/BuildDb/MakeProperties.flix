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

    use RelLib/Lattice/Constant.Constant;
    use RelLib/Lattice/Constant.{constant};

    /// use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, DateProperty};
    use S4Loader/PDT/BuildDb/Schema.{PDTRawValue, FieldEval,
        StringPropertyLat, IntPropertyLat, FloatPropertyLat, DatePropertyLat};
    

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
    pub def genProperties(input: #{PDTRawValue, FieldEval | r}): #{StringPropertyLat, IntPropertyLat, FloatPropertyLat, DatePropertyLat | r} = 
        /// use S4Loader/PDT/BuildDb/FieldEval.{stringAny, stringNonEmptyString, stringFloc, dateLocalDate};
        let rules = #{
            
            
            StringPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.stringAny(propValue)) :- 
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEval(propName, pdtAssetClass, "String", "builtin", "any").

            StringPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.stringNonEmptyString(propValue)) :- 
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEval(propName, pdtAssetClass, "String", "builtin", "non-empty-string").

            StringPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.stringFloc(propValue)) :- 
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEval(propName, pdtAssetClass, "String", "builtin", "floc").

            DatePropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.dateLocalDate(propValue)) :- 
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEval(propName, pdtAssetClass, "Date", "builtin", "local-date").

            IntPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.intInteger(propValue)) :-
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEval(propName, pdtAssetClass, "Int", "builtin", "integer").

            IntPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.intRegex(patt = patt, propValue)) :-
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEval(propName, pdtAssetClass, "Int", "regex", patt).

            FloatPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.decimalDecimal(propValue)) :-
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEval(propName, pdtAssetClass, "Decimal", "builtin", "decimal").

            FloatPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.decimalRegex(patt = patt, propValue)) :-
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEval(propName, pdtAssetClass, "Decimal", "regex", patt).

        };
        let input1 = input as #{PDTRawValue, FieldEval, 
                                StringPropertyLat, IntPropertyLat, FloatPropertyLat, DatePropertyLat | r};
        solve (input1 <+> rules) project StringPropertyLat, IntPropertyLat, FloatPropertyLat, DatePropertyLat



}
