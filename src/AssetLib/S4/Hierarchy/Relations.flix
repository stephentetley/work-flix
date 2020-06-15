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


namespace AssetLib/S4/Hierarchy/Relations {

    rel Node(id: String, description: String, parent: String)

    // Root has the same fields as Node but it's parent is just for "display" as the 
    // element it points to is not in the database.
    rel Root(id: String, description: String, parent: String)

    rel Child(id: String, description: String)



}