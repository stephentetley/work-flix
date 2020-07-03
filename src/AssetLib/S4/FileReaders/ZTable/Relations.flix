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


namespace AssetLib/S4/FileReaders/ZTable/Relations {

    rel Eqobjl(superObject: String, subObject: String, category: String)

    rel Flocdes(objectType: String, description: String)

    rel Floobjl(structure: String, superObject: String, subObject: String)

    rel Manuf(manufacturer: String, model: String)

    rel Obj(objectType: String, manufacturer: String)

}