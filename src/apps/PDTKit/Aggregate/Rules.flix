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

namespace PDTKit/Aggregate/Rules {

    use AssetLib/Base/AttributesLattice.{Attributes, AttributeValue};
    use AssetLib/Base/AttributesLattice.AttributeValue.{AttrString};

    use PDTKit/Aggregate/Schema.{Classification, ValueRow, AggregateRow};

    pub type alias AggregateSchema[r1: SchemaRow] = #{Classification, ValueRow, AggregateRow | r1}

    pub def makeAggregates(): AggregateSchema[r1] = 
        use AssetLib/Base/AttributesLattice.singleton;
        #{
            AggregateRow(assetName, sourceFile, classification; singleton(fieldName, AttrString(fieldValue))) :- 
                ValueRow(assetName, sourceFile, fieldName, fieldValue),
                Classification(sourceFile, classification).
        }
}
