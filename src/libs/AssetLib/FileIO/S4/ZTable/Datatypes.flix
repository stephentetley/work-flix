/*
 * Copyright 2020 Stephen Tetley
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


namespace AssetLib/FileIO/S4/ZTable/Datatypes {

    pub type alias EquiObject = 
        { category :: String
        , parent :: String
        , child :: String
        }

    pub type alias FlocObject = 
        { structure :: String
        , parent :: String
        , child :: String
        }

    pub type alias FlocDescription = 
        { objectType :: String
        , description :: String
        }

    pub type alias ObjTypeManufacturer = 
        { objectType :: String
        , manufacturer :: String
        }

    pub type alias ManufacturerModel = 
        { manufacturer :: String
        , model :: String
        }

}
