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


namespace AssetLib/S4/FileIO/ZTable/Datatypes {

    type alias Eqobjl = {superObject: String, subObject: String, category: String}

    type alias Flocdes = {objectType: String, description: String}

    type alias Floobjl = {structure: String, superObject: String, subObject: String}

    type alias Manuf = {manufacturer: String, model: String}

    type alias Obj = {objectType: String, manufacturer: String}

}