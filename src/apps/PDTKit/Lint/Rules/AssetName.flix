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

namespace PDTKit/Lint/Rules/AssetName {

    use PDTKit/Lint/Base/Schema.{Warning, PdtValueRow, MetaPdtAssetType};

    pub type alias InvalidAssetName[r1: SchemaRow] = #{Warning, PdtValueRow, MetaPdtAssetType | r1}

    pub def invalidAssetName(): InvalidAssetName[r1] = 
        #{
            
            ///
            Warning(sourceFile, row, column, warnTooLong(assetName)) :- 
                PdtValueRow(sourceFile, row, column, assetName, "Asset Name", assetName),
                if String.length(assetName) > 40.

            Warning(sourceFile, row, column, warnInvalidChars(assetName)) :- 
                PdtValueRow(sourceFile, row, column, assetName, "Asset Name", assetName),
                if testValidChars(assetName) == false.

        }

    def warnTooLong(assetName: String): String = 
        "Asset name too long: '${assetName}' is ${String.length(assetName)} characters (max length: 40)"

    def testValidChars(assetName: String): Bool = 
        String.forall(good, assetName)

    def good(c: Char): Bool= 
        let others = Set#{' ', '_', '-'};
        Char.isLetter(c) or Char.isDigit(c) or Set.memberOf(c, others)

    def warnInvalidChars(assetName: String): String = 
        let bad = assetName |> String.toList |> List.filter(c -> not good(c)) |> List.join("");
        "Asset name '${assetName}' contains invalid characters: '${bad}'"

}
