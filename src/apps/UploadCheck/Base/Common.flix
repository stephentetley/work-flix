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

use BasicDb.DbMonad;
use BasicDb/DbMonad.{prepareStatement, psExecuteQuery, optional, firstRow, rsClose};
use BasicDb.PreparedStatementSetter;
use BasicDb.RowEvaluator;

namespace UploadCheck/Base/Common {

    pub enum Datatype { 
        case Text,
        case Date,
        case Integer,
        case Decimal
    }

    pub def decodeDatatype(name: String): Option[Datatype] = match name {
        case "Text" => Some(Text)
        case "Date" => Some(Date)
        case "Int" => Some(Integer)
        case "Decimal" => Some(Decimal)
        case _ => None
    }

    pub def datatypeName (x: Datatype): String = match x {
        case Text => "Text"
        case Date => "Date"
        case Integer => "Integer"
        case Decimal => "Decimal"
    }

} 