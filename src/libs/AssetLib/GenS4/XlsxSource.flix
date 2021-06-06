/*
 * Copyright 2021 Stephen Tetley
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


namespace AssetLib/GenS4/XlsxSource {
    use BasicJson.JsonReader;

    type alias XlsxSource = 
        { file: System.FilePath
        , sheet: String
        }

    pub def ofString(s: String): XlsxSource = match String.breakOnLeft("##", s) {
        case (s1, s2) if String.isEmpty(s2) => {file = System/FilePath.new(s1), sheet = "Sheet1"}
        case (s1, s2) => {file = System/FilePath.new(s1), sheet = Option.getWithDefault(String.stripPrefix("##", s2), "")}
    }
    
    pub def getXlsxSource(): JsonReader[XlsxSource] = 
        use BasicJson/JsonReader.{withField, getString, filePath};
        use BasicJson/JsonReader.{<&>, <*>};
        ((x1, x2) -> {file = x1, sheet = x2})
            <&> withField("file", filePath())
            <*> withField("sheet", getString())



}
