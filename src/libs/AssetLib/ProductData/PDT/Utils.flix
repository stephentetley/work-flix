/*
 * Copyright 2021 Stephen Tetley
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

namespace AssetLib/ProductData/PDT/Utils {

    use SheetIO/SheetParser.SheetParser;

    use AssetLib/S4Lite/Datatypes.{UxlSource, SLEquipment, SLEquiCharacteristic, SLDatatype};
    use AssetLib/S4Lite/Datatypes.SLDatatype.{Character, NumericInt, NumericFloat};

    pub def validFromToday(): SheetParser[ka1, Time.LocalDate] =
        SheetIO/SheetParser.liftAction(_ -> Time/LocalDate.now())

    pub def rowKeyValue(key: String): SheetParser[ka1, String] =
        use SheetIO/SheetParser.{row, literal, content, swapError};
        use SheetIO/SheetParser.{*>};
        row(literal(key) *> content()) `swapError` "rowKeyLocalDate - key=${key}"

    pub def rowKeyLocalDate(key: String): SheetParser[ka1, Time.LocalDate] =
        use SheetIO/SheetParser.{row, literal, localDate, swapError};
        use SheetIO/SheetParser.{*>};
        row(literal(key) *> localDate()) `swapError` "rowKeyLocalDate - key=${key}"

    pub def getUNICLASS_CODE(equiId: String, className: String): SheetParser[ka1, SLEquiCharacteristic] = 
        use SheetIO/SheetParser.{return};
        return(
            { equiId = equiId
            , className = className
            , charName = "UNICLASS_CODE"
            , valueType = Character
            , intCounterValue = 1
            , charValue = ""
            })

    pub def getUNICLASS_DESC(equiId: String, className: String): SheetParser[ka1, SLEquiCharacteristic] = 
        use SheetIO/SheetParser.{return};
        return(
            { equiId = equiId
            , className = className
            , charName = "UNICLASS_DESC"
            , valueType = Character
            , intCounterValue = 1
            , charValue = ""
            })
}
