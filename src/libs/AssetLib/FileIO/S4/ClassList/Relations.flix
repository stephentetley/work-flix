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


namespace AssetLib/FileIO/S4/ClassList/Relations {

    use AssetLib/FileIO/S4/ClassList/Datatypes.{Class => ClassRecord};

    pub rel S4Class(name: String, description: String, classtype: String)

    pub rel S4Characteristic(name: String, description: String, chartype: String)

    pub rel S4ClassMember(classname: String, charname: String)

    pub def loadFlocClassRelations(path: System.FilePath): Result[#{S4Class, S4Characteristic, S4ClassMember | r}, String] & Impure = 
        use Result.{flatMap};
        let* x1     = AssetLib/FileIO/S4/ClassList/Builder.loadFlocClassList(path);
        let relns   = makeRelations(x1.classes);
        Ok(relns)

    pub def loadEquiClassRelations(path: System.FilePath): Result[#{S4Class, S4Characteristic, S4ClassMember | r}, String] & Impure = 
        use Result.{flatMap};
        let* x1     = AssetLib/FileIO/S4/ClassList/Builder.loadEquiClassList(path);
        let relns   = makeRelations(x1.classes);
        Ok(relns)


    pub def makeRelations(xs: List[ClassRecord]): #{S4Class, S4Characteristic, S4ClassMember | r} = 
        Relation.foldMap(x1 -> makeClass(x1) <+> makeChars(x1) <+> makeClassMembers(x1), xs)

    def makeClass(x: ClassRecord): #{S4Class | r} = #{ S4Class(x.name, x.description, x.classtype). }

    def makeChars(x: ClassRecord): #{S4Characteristic | r} = 
        use AssetLib/FileIO/S4/ClassList/Datatypes.{s4TypeName};
        Relation.foldMap(x1 -> #{ S4Characteristic(x1.name, x1.description, s4TypeName(x1.chartype)). }, x.characteristics)

    def makeClassMembers(x: ClassRecord): #{S4ClassMember | r} = 
        Relation.foldMap(x1 -> #{ S4ClassMember(x.name, x1.name). }, x.characteristics)


}