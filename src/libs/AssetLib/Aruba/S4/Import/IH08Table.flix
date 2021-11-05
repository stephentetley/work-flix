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

namespace AssetLib/Aruba/S4/Import/IH08Table {
    
    use SheetIO/Reader.{XlsxSource};
    use SheetIO.NamedRowEvaluator;

    use AssetLib/Aruba/S4/Hierarchy.{S4EquiType};

    /// TODO - read Base relations (alternative input source to Structure List)



    pub def readS4EquiTypes(src: XlsxSource): Result[#{S4EquiType | r}, String] & Impure =         
        SheetIO/Reader.someNamedRelations(src, evalS4EquiType())

    def evalS4EquiType(): NamedRowEvaluator[#{S4EquiType | r}] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getLocalDateNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> #{ S4EquiType(x1, x2). })
            <&> getTrimmedContentNamed("Equipment")
            <*> getTrimmedContentNamed("Object Type")
            


}
