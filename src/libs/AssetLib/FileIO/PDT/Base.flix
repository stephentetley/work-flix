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

namespace AssetLib/FileIO/PDT/Base {


    pub rel FieldValue(fileName: String, 
                            rowNum: Int32, 
                            colNum: Int32, 
                            assetName: String, 
                            fieldName: String, 
                            fieldValue: String, 
                            fieldUnits: String)


    pub type alias PDTValueRow = 
        { rowNumber :: Int32
        , rowName :: String
        , cellValues :: List[String]
        }


    /// The first n rows (currently n=8)
    pub type alias ADTMetaData = 
        { metaName :: String
        , metaValue :: String
        }

    // Value Column [col 3] is not useful
    pub type alias ADTParamRow = 
        { rowNumber :: Int32
        , category :: String
        , paramName :: String
        , paramUnits :: String
        , notes :: String
        }


}
