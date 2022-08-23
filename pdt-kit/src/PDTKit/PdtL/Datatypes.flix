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


namespace PDTKit/PdtL/Datatypes {

    // pub type alias PdtFile = 
    //     { leadSheet :: 
                // { headings :: List[SectionHeading]
                // , attributes :: List[LeadSheetAttribute]
                // }
    //     , dataDictionary :: List[DataDictionaryRow]
    //     , datasheet :: 
    //         { sheetName :: String
    //         , rows :: List[DataSheetRow]
    //         }
    //     }


    pub type alias SectionHeading = 
        { rowNum :: Int32
        , heading :: String
        }

    pub type alias LeadSheetAttribute = 
        { rowNum :: Int32
        , name :: String
        , value :: String
        , code :: String
        }

    pub type alias DDMetadata = 
        { rowNum :: Int32
        , name :: String
        , value :: String
        }

    pub type alias DDAttribute = 
        { rowNum :: Int32
        , name :: String
        , value :: String
        , units :: String
        }

    // pub type alias DataSheetRow = 
    //     { rowNum :: Int32
    //     , fieldName :: String
    //     , size :: Int32
    //     , values :: List[String]
    //     }


}
