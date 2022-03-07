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

namespace Aruba/S4/Import/DeleteList {

    use Functor.{<$>};
    use Applicative.{<*>};

    use SheetIO/Reader.{XlsxSource};
    use SheetIO.NamedRowEvaluator;

    use Aruba/S4/Base.{S4Floc, S4Equi};


    pub def readFlocDeleteList(src: XlsxSource): Result[#{S4Floc | r}, String] & Impure =
        SheetIO/Reader.someNamedRelations(evalFlocDelete(), src)

    def evalFlocDelete(): NamedRowEvaluator[#{S4Floc | r}] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getLocalDateNamed};
        ((x1, x2) -> RelLib/Relation.whenTrue(not String.isEmpty(x1) and not String.isEmpty(x2),  #{ S4Floc(x1, x2). }))
            <$> getTrimmedContentNamed("Functional Location")
            <*> getTrimmedContentNamed("S4 Name")

    pub def readEquiDeleteList(src: XlsxSource): Result[#{S4Equi | r}, String] & Impure =         
        SheetIO/Reader.someNamedRelations(evalEquiDelete(), src)

    def evalEquiDelete(): NamedRowEvaluator[#{S4Equi | r}] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getLocalDateNamed};
        ((x1, x2) -> RelLib/Relation.whenTrue(not String.isEmpty(x1) and not String.isEmpty(x2),  #{ S4Equi(x1, x2). }))
            <$> getTrimmedContentNamed("Equi Id")
            <*> getTrimmedContentNamed("S4 Name")


}
