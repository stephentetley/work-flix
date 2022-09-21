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


namespace AssetLib/GenS4/AibFacts/Attributes/MemoLines {

    use Functor.{<$>};
    use Applicative.{<*>};

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use Compatibility.{XlsxSource};

    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{AibMemoLine};



    /// Read from Aib file...

    pub def readMemoLinesData(src: XlsxSource): GenMonad[#{AibMemoLine | r}] =
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/Reader.someNamedRelations(evalAibMemoLine(), src))
        
    

    /// TODO AibMemoLine - String[Set] wrong latticetype as loses order
    def evalAibMemoLine(): NamedRowEvaluator[#{AibMemoLine | r}] =
        use SheetIO/NamedRowEvaluator.{withDefault, getNonEmptyContentNamed, getContentNamed}; 
        ((x1, x2, x3, x4, x5, x6) -> { 
                makeMemo(x1, 1, x2) <+> makeMemo(x1, 2, x3) <+> makeMemo(x1, 3, x4)
                    <+> makeMemo(x1, 4, x5) <+> makeMemo(x1, 5, x6)                 
            })
            <$> getNonEmptyContentNamed("Reference")
            <*> withDefault(getNonEmptyContentNamed("Memo Line 1"), "")
            <*> withDefault(getNonEmptyContentNamed("Memo Line 2"), "")
            <*> withDefault(getNonEmptyContentNamed("Memo Line 3"), "")
            <*> withDefault(getNonEmptyContentNamed("Memo Line 4"), "")
            <*> withDefault(getNonEmptyContentNamed("Memo Line 5"), "")

    def makeMemo(aibref: String, ix: Int32, s: String): #{AibMemoLine | r} = 
        if (String.isEmpty(s)) 
            #{}
        else 
            #{ AibMemoLine(aibref; AssetLib/GenS4/Base/OrderedStrings.singleton(ix, s)). }


}
