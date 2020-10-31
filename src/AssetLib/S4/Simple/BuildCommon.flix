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

namespace AssetLib/S4/Simple/BuildCommon {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/S4/Simple/Datatypes.{Classification, LongText};

    pub def evalClassification(): RowEvaluator[Classification] = 
        use BasicDb/RowEvaluator.{flatMap, return, getStringNamed, getFloat64Named};
        let* classname  = getStringNamed("class_name");
        let* charname   = getStringNamed("charname");
        let* datatype   = getStringNamed("datatype");
        let* value      = getValue(datatype);
        return( 
            { className = classname
            , charName  = charname
            , datatype  = datatype
            , value     = value
            })

    pub def getValue(datatype: String): RowEvaluator[String] =
        use BasicDb/RowEvaluator.{map, getStringNamed, getFloat64Named};
        if (datatype == "Int" || datatype == "Decimal")
            map(Float64.toString, getFloat64Named("value_from"))
        else
            getStringNamed("value_description")

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