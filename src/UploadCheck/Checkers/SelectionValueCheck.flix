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


use AssetLib/S4/FileIO/ClassList/Relations.{SelectionValue};


namespace UploadCheck/Checkers/SelectionValueCheck {

    pub def selectionValueCheck[r](db: #{SelectionValue, Restricted, RestrictedValue | r}, charname: String, value: String): Bool = 
        isRestricted(db, charname) && isRestrictedValue(db, charname, value)

    rel Restricted(charname: String)

    def isRestricted[r](db: #{SelectionValue, Restricted | r}, charname: String): Bool = 
        let rules = #{
            Restricted(name) :- SelectionValue(name, _).
        };
        (solve db <+> rules) |= Restricted(charname).

    rel RestrictedValue(charname: String, value: String)

    def isRestrictedValue[r](db: #{SelectionValue, RestrictedValue | r}, charname: String, value: String): Bool = 
        let rules = #{
            RestrictedValue(name, valu) :- SelectionValue(name, valu).
        };
        (solve db <+> rules) |= RestrictedValue(charname, value).

}