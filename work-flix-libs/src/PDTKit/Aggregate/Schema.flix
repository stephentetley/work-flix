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

namespace PDTKit/Aggregate/Schema {

    use Compatibility/Lattice/StringAttributes.{StringAttributes};
    use Compatibility/Lattice/Int32StringAttributes.{Int32StringAttributes};

    pub rel Classification(sourceFile: String, classification: String)

    pub rel ValueRow(assetName: String, sourceFile: String, sourceItem: Int32, fieldName: String, fieldValue: String)

    pub rel ParamSpec(classification: String, paramName: String, paramIndex: Int32)

    /// Store properties in a Map lattice...
    pub lat AggregateRow(classification: String, sourceFile: String, column: Int32, assetName: String, attributes: StringAttributes)

    pub lat TabSpec(classification: String, columns: Int32StringAttributes)

}
