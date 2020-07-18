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

use System.Error.{IllegalArgumentException, Generic};

namespace AssetLib/Common/Utils {

    pub def traverseX(fn: a -> Result[b, e] & f, xs: List[a]): Result[Unit, e] & f = match xs { 
        case x :: rs => match fn(x) {
            case Ok(_) => traverseX(fn, rs)
            case Err(e) => Err(e)
        }
        case Nil => Ok() 
    }

    pub def traverseOptionX(fn: a -> Option[b] & f, xs: List[a]): Option[Unit] & f = match xs { 
        case x :: rs => match fn(x) {
            case Some(_) => traverseOptionX(fn, rs)
            case None => None
        }
        case Nil => Some() 
    }

}