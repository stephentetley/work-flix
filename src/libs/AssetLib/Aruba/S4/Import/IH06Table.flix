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

namespace AssetLib/Aruba/S4/Import/IH06Table {
    
    use SheetIO/Reader.{XlsxSource};
    use SheetIO.NamedRowEvaluator;

    use AssetLib/Aruba/S4Hierarchy.{S4FlocType};

    /// TODO - read Base relations (alternative input source to Structure List)



    pub def readS4FlocTypes(src: XlsxSource): Result[#{S4FlocType | r}, String] & Impure =         
        SheetIO/Reader.someNamedRelations(src, evalS4FlocType())

    def evalS4FlocType(): NamedRowEvaluator[#{S4FlocType | r}] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getLocalDateNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> #{ S4EquiType(x1, x2). })
            <&> getTrimmedContentNamed("Functional Loc.")
            <*> getTrimmedContentNamed("Object Type")
            


}
