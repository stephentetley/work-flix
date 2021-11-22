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

namespace AssetLib/Aruba/S4/Import/DeleteList {
    
    use SheetIO/Reader.{XlsxSource};
    use SheetIO.NamedRowEvaluator;

    pub rel S4DeleteItem(uid: String, description: String)


    pub def readDeleteList(src: XlsxSource): Result[#{S4DeleteItem | r}, String] & Impure =         
        SheetIO/Reader.someNamedRelations(evalS4DeleteItem(), src)

    def evalS4DeleteItem(): NamedRowEvaluator[#{S4DeleteItem | r}] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getLocalDateNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> RelLib/Relation.whenTrue(not String.isEmpty(x1) and not String.isEmpty(x2),  #{ S4DeleteItem(x1, x2). }))
            <&> getTrimmedContentNamed("Equi Id")
            <*> getTrimmedContentNamed("S4 Name")


}
