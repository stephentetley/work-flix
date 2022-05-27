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


namespace S4Loader/PDT/Rules/EquiClasses/OneToOneMapping {

    use S4Loader/Base/Schema.{DirectMapping};

    /// Tiny dsl to specify class / characteristic mappings...

    type alias OneToOneMapping = 
        { s4Class :: String
        , pdtObjectType :: String
        , properties :: List[{s4Characteristic :: String, pdtField :: String}]
        }


    pub type alias OneToOneMappingBuilder = OneToOneMapping -> OneToOneMapping

    pub def property(s4Name: String, pdtField: String): OneToOneMappingBuilder = mapping -> 
        {properties = {s4Characteristic = s4Name, pdtField = pdtField} :: mapping.properties | mapping}

    pub def directMapping(s4Class: String, pdtObjectType: String): OneToOneMapping  =  
        {s4Class = s4Class, pdtObjectType = pdtObjectType, properties = Nil}
    

    pub def makeRelations(m: OneToOneMapping): #{DirectMapping | r} = 
        RelLib/Relation.foldMap(r -> #{ DirectMapping(m.pdtObjectType, r.pdtField, m.s4Class, r.s4Characteristic). }, m.properties)





}
