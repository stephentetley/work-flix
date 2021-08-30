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

    pub rel S4FlocClass(name: String, description: String)

    pub rel S4FlocCharacteristic(name: String, description: String, chartype: String)

    pub rel S4FlocClassMember(classname: String, charname: String)

    pub rel S4EquiClass(name: String, description: String)

    pub rel S4EquiCharacteristic(name: String, description: String, chartype: String)

    pub rel S4EquiClassMember(classname: String, charname: String)

    pub def loadFlocClassRelations(path: System.FilePath): Result[#{S4FlocClass, S4FlocCharacteristic, S4FlocClassMember | r}, String] & Impure = 
        use Result.{flatMap};
        let* x1     = AssetLib/FileIO/S4/ClassList/Builder.loadFlocClassList(path);
        let relns   = makeFlocRelations(x1.classes);
        Ok(relns)

    pub def loadEquiClassRelations(path: System.FilePath): Result[#{S4EquiClass, S4EquiCharacteristic, S4EquiClassMember | r}, String] & Impure = 
        use Result.{flatMap};
        let* x1     = AssetLib/FileIO/S4/ClassList/Builder.loadEquiClassList(path);
        let relns   = makeEquiRelations(x1.classes);
        Ok(relns)


    pub def makeFlocRelations(xs: List[ClassRecord]): #{S4FlocClass, S4FlocCharacteristic, S4FlocClassMember | r} = 
        Relation.foldMap(x1 -> makeFlocClass(x1) <+> makeFlocChars(x1) <+> makeFlocClassMembers(x1), xs)

    def makeFlocClass(x: ClassRecord): #{S4FlocClass | r} = #{ S4FlocClass(x.name, x.description). }

    def makeFlocChars(x: ClassRecord): #{S4FlocCharacteristic | r} = 
        use AssetLib/FileIO/S4/ClassList/Datatypes.{s4TypeName};
        Relation.foldMap(x1 -> #{ S4FlocCharacteristic(x1.name, x1.description, s4TypeName(x1.chartype)). }, x.characteristics)

    def makeFlocClassMembers(x: ClassRecord): #{S4FlocClassMember | r} = 
        Relation.foldMap(x1 -> #{ S4FlocClassMember(x.name, x1.name). }, x.characteristics)



    pub def makeEquiRelations(xs: List[ClassRecord]): #{S4EquiClass, S4EquiCharacteristic, S4EquiClassMember | r} = 
        Relation.foldMap(x1 -> makeEquiClass(x1) <+> makeEquiChars(x1) <+> makeEquiClassMembers(x1), xs)

    def makeEquiClass(x: ClassRecord): #{S4EquiClass | r} = #{ S4EquiClass(x.name, x.description). }

    def makeEquiChars(x: ClassRecord): #{S4EquiCharacteristic | r} = 
        use AssetLib/FileIO/S4/ClassList/Datatypes.{s4TypeName};
        Relation.foldMap(x1 -> #{ S4EquiCharacteristic(x1.name, x1.description, s4TypeName(x1.chartype)). }, x.characteristics)

    def makeEquiClassMembers(x: ClassRecord): #{S4EquiClassMember | r} = 
        Relation.foldMap(x1 -> #{ S4EquiClassMember(x.name, x1.name). }, x.characteristics)

}