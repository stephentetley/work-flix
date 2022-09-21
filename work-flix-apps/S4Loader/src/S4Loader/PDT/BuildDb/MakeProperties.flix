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

    use Basis/System.FilePath;
    use BasicDb.DbMonad;
    use BasicDb.RowEvaluator;

    use RelLib/Lattice/Constant.Constant;
    use RelLib/Lattice/Constant.{constant};

    /// use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, DateProperty};
    use S4Loader/PDT/BuildDb/Schema.{PDTRawValue, FieldEvalSpec, FieldValueEnum,
        StringPropertyLat, IntPropertyLat, FloatPropertyLat, DatePropertyLat};
    

    /// Reads from another SQLite db...
    pub def readPDTRawValues(path: {pathToPdtDb :: FilePath}, viewName: String): DbMonad[#{PDTRawValue| r}] = 
        let sql = "SELECT item_name, pdt_class_name, field_name, field_value FROM ${viewName} ORDER BY item_name;";
        BasicDb/DbMonad.localSQLiteConnection(path.pathToPdtDb, BasicDb/Reader.allRelations(evalPDTRawValue(), sql))

    def evalPDTRawValue(): RowEvaluator[#{PDTRawValue | r}] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2, x3, x4) -> #{ PDTRawValue(x1, x2, x3, x4). })
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)
            <*> getStringAt(3)

    ///
    /// This doesn't have (proper) access to S4_Class_Type so it can produce e.g. enums that are not 
    /// accepted by the S4_Class_Type, int or decimal values out of range...
    ///
    pub def genProperties(input: #{PDTRawValue, FieldEvalSpec, FieldValueEnum | r}): #{StringPropertyLat, IntPropertyLat, FloatPropertyLat, DatePropertyLat | r} = 
        /// use S4Loader/PDT/BuildDb/FieldEval.{stringAny, stringNonEmptyString, stringFloc, dateLocalDate};
        let rules = #{
            
            
            StringPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.stringAny(propValue)) :- 
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "String", "builtin", "any", _).

            StringPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.stringNonEmptyString(propValue)) :- 
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "String", "builtin", "non-empty-string", _).

            StringPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.stringFloc(propValue)) :- 
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "String", "builtin", "floc", _).

            StringPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.stringIPRating(propValue)) :- 
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "String", "builtin", "ip-rating", _).


            StringPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.stringRegex(patt = patt, propValue)) :-
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "String", "regex", patt, _).

            StringPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.stringAssetStatus(propValue)) :- 
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "String", "builtin", "asset-status", _).

            StringPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.stringAssetType(propValue)) :- 
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "String", "builtin", "asset-type", _).

            StringPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.stringManufacturer(propValue)) :- 
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "String", "builtin", "manufacturer", _).


            StringPropertyLat(uid, propName; constant(enumValue)) :- 
                PDTRawValue(uid, pdtAssetClass, propName, rawValue),
                FieldEvalSpec(propName, pdtAssetClass, "String", "enum", _, _),
                FieldValueEnum(propName, pdtAssetClass, rawValue, enumValue).


            // Date 
            DatePropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.dateLocalDate(propValue)) :- 
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "Date", "builtin", "local-date", _).

            // Int
            IntPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.intInteger(propValue)) :-
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "Int", "builtin", "integer", _).

            IntPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.intIntegerWithUnits(unitsName = arg1, propValue)) :-
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "Int", "builtin", "integer-with-units", arg1).

            IntPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.intRegex(patt = patt, propValue)) :-
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "Int", "regex", patt, _).


            // Float
            FloatPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.decimalDecimal(propValue)) :-
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "Decimal", "builtin", "decimal", _).

            FloatPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.decimalDecimalWithUnits(unitsName = arg1, propValue)) :-
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "Decimal", "builtin", "decimal-with-units", arg1).

            FloatPropertyLat(uid, propName; S4Loader/PDT/BuildDb/FieldEval.decimalRegex(patt = patt, propValue)) :-
                PDTRawValue(uid, pdtAssetClass, propName, propValue),
                FieldEvalSpec(propName, pdtAssetClass, "Decimal", "regex", patt, _).

        };
        let input1 = input as #{PDTRawValue, FieldEvalSpec, FieldValueEnum,
                                StringPropertyLat, IntPropertyLat, FloatPropertyLat, DatePropertyLat | r};
        solve (input1 <+> rules) project StringPropertyLat, IntPropertyLat, FloatPropertyLat, DatePropertyLat



}
