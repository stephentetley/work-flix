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

namespace AssetS/ChangeReport/Relations {

    use AssetS/ChangeReport/Lattice/Max.{Max};
    use AssetS/ChangeReport/Lattice/Min.{Min};

    // SourceRow => SimpleRow => Change

    pub rel SourceRow(
        rowIx: Int32,
        entityType: String, 
        itemId: String,             // floc | internal floc id | equiId
        charId: String, 
        className: String, 
        language: String, 
        intCounter: String, 
        addressNumber: String, 
        change: String, 
        attrib: String, 
        oldValue: String, 
        newValue: String,
        table: String
    )

    pub rel SimpleRow(rowIx: Int32, compoundKey: String, change: String, oldValue: String, newValue: String)

    pub rel Change(compoundKey: String, change: String, oldValue: String, newValue: String)

}
