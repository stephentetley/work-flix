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

namespace AssetLib/AibFacts/Relations {

    use SheetIO.NamedRowEvaluator;

    pub rel AibStringValue(aibref: String, valueName: String, value: String)

    pub rel AibIntValue(aibref: String, valueName: String, value: Int32)

    pub rel AibFloatValue(aibref: String, valueName: String, value: Float64)


    pub def getStringValue(columnName: String, factName: String): NamedRowEvaluator[#{AibStringValue | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed, getNonEmptyContentNamed};  
        let* x1     = getContentNamed("Reference");
        let* x2     = getNonEmptyContentNamed(columnName);
        return(#{ AibStringValue(x1, factName, x2). })
        
    pub def getIntValue(columnName: String, factName: String): NamedRowEvaluator[#{AibIntValue | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed, getInt32Named};  
        let* x1     = getContentNamed("Reference");
        let* x2     = getInt32Named(columnName);
        return(#{ AibIntValue(x1, factName, x2). })



    pub def getAttributes(xs: List[NamedRowEvaluator[#{| r}]]): NamedRowEvaluator[#{| r}] = 
        getAttributesHelper(xs, #{})

    /// This NamedRowEvaluator always succeeds - if an individual evaluator fails it returns `#{}`
    /// which is concatenated with all the other successes and failures
    def getAttributesHelper(xs: List[NamedRowEvaluator[#{| r}]], 
                            ac: #{| r}): NamedRowEvaluator[#{| r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};
        match xs { 
            case eval1 :: rs => {
                let* r1 = withDefault(eval1, #{});
                getAttributesHelper(rs, ac <+> r1)
            }
            case Nil => return(ac)
        }

}
