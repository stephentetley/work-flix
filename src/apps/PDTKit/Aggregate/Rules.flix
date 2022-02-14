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
            AggregateRow(classification, assetName, sourceFile; singleton(makeKey(2, "Asset Type"), fieldValue)) :- 
                ValueRow(assetName, sourceFile, "Asset Type", fieldValue),
                Classification(sourceFile, classification).
            
            AggregateRow(classification, assetName, sourceFile; singleton(makeKey(3, "Asset Status"), fieldValue)) :- 
                ValueRow(assetName, sourceFile, "Asset Status", fieldValue),
                Classification(sourceFile, classification).

            AggregateRow(classification, assetName, sourceFile; singleton(makeKey(4, "Uniclass Code"), fieldValue)) :- 
                ValueRow(assetName, sourceFile, "Uniclass Code", fieldValue),
                Classification(sourceFile, classification).

            AggregateRow(classification, assetName, sourceFile; singleton(makeKey(5, "Uniclass Description"), fieldValue)) :- 
                ValueRow(assetName, sourceFile, "Uniclass Description", fieldValue),
                Classification(sourceFile, classification).

            AggregateRow(classification, assetName, sourceFile; singleton(makeKey(paramIndex + 10, fieldName), fieldValue)) :- 
                ValueRow(assetName, sourceFile, fieldName, fieldValue),
                Classification(sourceFile, classification),
                ParamSpec(classification, fieldName, paramIndex).

            

            TabSpec(classification; singleton(makeKey(0, ""), "Asset Name")) :- Classification(_, classification).
            TabSpec(classification; singleton(makeKey(1, ""), "Source File")) :- Classification(_, classification).
            TabSpec(classification; singleton(makeKey(2, ""), "Asset Type")) :- Classification(_, classification).
            TabSpec(classification; singleton(makeKey(3, ""), "Asset Status")) :- Classification(_, classification).
            
            TabSpec(classification; singleton(makeKey(paramIndex + 10, ""), fieldName)) :- ParamSpec(classification, fieldName, paramIndex).
        }

    def makeKey(ix: Int32, fieldName: String): String  = 
        let index = String.padLeft(3, '0', ToString.toString(ix));
        "${index}:${fieldName}"

}
