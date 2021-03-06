/*
 * Copyright 2020 Stephen Tetley
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

namespace AssetLib/S4Lite/CreateNew/Common {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/S4Lite/CreateNew/Datatypes.{Classification, LongText, Value, ValueType};
    use AssetLib/S4Lite/CreateNew/Datatypes.Value.{Text, Integer, Decimal};
    use AssetLib/S4Lite/CreateNew/Datatypes.ValueType.{TextType, IntegerType, DecimalType};

    pub def evalClassification(): RowEvaluator[Classification] = 
        use BasicDb/RowEvaluator.{flatMap, return, getStringNamed, getFloat64Named};
        let* classname  = getStringNamed("class_name");
        let* charname   = getStringNamed("charname");
        let* datatype   = getValueTypeNamed("datatype");
        let* value      = getValue(datatype);
        return( 
            { className = classname
            , charName  = charname
            , value     = value
            })

    pub def getValueTypeNamed(field: String): RowEvaluator[ValueType] =
        use BasicDb/RowEvaluator.{flatMap, return, getStringNamed, throwError};
        let* s  = getStringNamed(field);
        match String.toUpperCase(s) { 
            case s1 if (s1 == "TEXT")       => return(TextType)
            case s1 if (s1 == "INTEGER")    => return(IntegerType)
            case s1 if (s1 == "DECIMAL")    => return(DecimalType)
            case _                          => throwError("getValueTypeNamed - unrecognized `${s}`")
        }


    pub def getValue(datatype: ValueType): RowEvaluator[Value] =
        use BasicDb/RowEvaluator.{map, getStringNamed, getInt32Named, getFloat64Named};
        match datatype {
            case TextType => map(Text, getStringNamed("value_description"))     /// different field!
            case IntegerType => map(Integer, getInt32Named("value_from"))
            case DecimalType => map(Decimal, getFloat64Named("value_from"))
        }
            

    pub def evalLongText(): RowEvaluator[LongText] = 
        use BasicDb/RowEvaluator.{flatMap, return, getStringNamed, getFloat64Named};
        use BasicDb/RowEvaluator.{<&>, <*>};
        ((x1, x2) -> 
                { shortText = x1
                , longText  = x2
                })
            <&> getStringNamed("short_text")
            <*> getStringNamed("long_text")


}