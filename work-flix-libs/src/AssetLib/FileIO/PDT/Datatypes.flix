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

/// Note
/// This component reads and "packages" PDT data for analysis, "output" is to SQLite.
/// There is no intention for "roundtripping" unlike Transfer files for instance.

namespace AssetLib/FileIO/PDT/Datatypes {

    /// Note - we use Datalog for a join (maybe we could do it in SQL 
    /// when we ingest the data).
    pub rel FieldValue(fileName: String, 
                            pdtClassName: String,
                            rowNum: Int32, 
                            colNum: Int32, 
                            assetName: String, 
                            fieldName: String, 
                            fieldValue: String)


    pub type alias PDTValueRow = 
        { fileName :: String
        , pdtClassName :: String
        , rowNumber :: Int32
        , rowName :: String
        , cellValues :: List[String]
        }


    /// The first n rows (currently n=8)
    pub type alias ADTHeaderRow = 
        { fileName :: String
        , rowNumber :: Int32
        , metaName :: String
        , metaValue :: String
        }

    /// Value Column [col 3] we call `paramIndex` - this is used
    /// for ordering the fields of an aggregate 
    pub type alias ADTParamRow = 
        { fileName :: String
        , rowNumber :: Int32
        , category :: String
        , paramName :: String
        , paramIndex :: Int32
        , paramUnits :: String
        , notes :: String
        }


}
