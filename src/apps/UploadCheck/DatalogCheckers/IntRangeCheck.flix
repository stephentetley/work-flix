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


use AssetLib/S4/FileIO/ClassList/Relations.{IntRange};


namespace UploadCheck/DatalogCheckers/IntRangeCheck {

    pub def intRangeCheck[r](db: #{IntRange, Restricted | r}, charname: String, value: Int32): Bool = 
        isRestricted(db, charname) and isRestrictedValue(db, charname, value)

    rel Restricted(charname: String)

    def isRestricted[r](db: #{IntRange, Restricted | r}, charname: String): Bool = 
        let rules = #{
            Restricted(name) :- IntRange(name, _, _).
        };
        (solve db <+> rules) |= Restricted(charname).

    
    def isRestrictedValue[r](db: #{IntRange, Restricted | r}, charname: String, value: Int32): Bool = 
        let rules = #{
            Restricted(name) :- IntRange(name, low, high), if low <= value and value <= high.
        };
        (solve db <+> rules) |= Restricted(charname).

}