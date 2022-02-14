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

    use RelLib/Lattice/StringAttributes.{StringAttributes};   /// TODO can we have a polymorphic Map lattice in RelLib?


    use PDTKit/Aggregate/Schema.{Classification, ValueRow, ParamSpec, AggregateRow, TabSpec};



    pub type alias AggregateSchema[r1: SchemaRow] = #{Classification, ValueRow, ParamSpec, AggregateRow, TabSpec | r1}

    pub def makeAggregates(): AggregateSchema[r1] = 
        use RelLib/Lattice/StringAttributes.singleton;
        #{
            ///
            AggregateRow(classification, assetName, sourceFile; RelLib/Lattice/StringAttributes.singleton(fieldName, fieldValue)) :- 
                ValueRow(assetName, sourceFile, fieldName, fieldValue),
                Classification(sourceFile, classification).

            TabSpec(classification; RelLib/Lattice/Int32StringAttributes.singleton(paramIndex, fieldName)) :- 
                ParamSpec(classification, fieldName, paramIndex).
        }

    pub def columnsPrefix(): List[String] = 
        "Asset Name" :: "Source File" :: "Asset Type" :: "Asset Status" :: Nil

}
