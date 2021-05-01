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
    use SheetIO.SheetReader;

    /// Aib has no notion of a "Fact Group" but we need it to signal a "class" when 
    /// connection between Aib and S4.
    pub rel AibFactGroup(aibref: String, groupName: String)

    pub rel AibStringValue(aibref: String, valueName: String, value: String)

    pub rel AibIntValue(aibref: String, valueName: String, value: Int32)

    pub rel AibFloatValue(aibref: String, valueName: String, value: Float64)



    pub def readAibFacts(eval: NamedRowEvaluator[#{| r}], 
                        sheetName: String, 
                        path: System.FilePath): Result[#{| r}, String] & Impure =
        SheetIO/SheetReader.runXlsx(readAibSheet(eval, sheetName), path)
        

    pub def readAibSheet(eval: NamedRowEvaluator[#{| r}], sheetName: String): SheetReader[#{| r}] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};         
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, eval);
        let relns   = List.foldLeft((ac, x) -> ac <+> x, #{}, xs);
        return(relns)


    pub def getFactGroup(groupName: String): NamedRowEvaluator[#{AibFactGroup | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed};  
        let* x1     = getContentNamed("Reference");
        return(#{ AibFactGroup(x1, groupName). })

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

    pub def getFloatValue(columnName: String, factName: String): NamedRowEvaluator[#{AibFloatValue | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed, getFloat64Named};  
        let* x1     = getContentNamed("Reference");
        let* x2     = getFloat64Named(columnName);
        return(#{ AibFloatValue(x1, factName, x2). })

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


    /// Must find the `parent` and attribute that identifies the group and at least one element of `xs`
    pub def getAttributeGroup(parent: NamedRowEvaluator[#{| r}], 
                                xs: List[NamedRowEvaluator[#{| r}]]): NamedRowEvaluator[#{| r}] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional};
        let* start = optional(parent);
        match start {
            case Some(r1) => { 
                let* ans = getAttributeGroupHelper(xs, (false, #{}));
                match ans { 
                    case Some(kids) => return(r1 <+> kids)
                    case None => return(#{})
                }
            }
            case None => return(#{})
        }

    /// Find at least one from `xs`
    def getAttributeGroupHelper(xs: List[NamedRowEvaluator[#{| r}]], 
                                ac: (Bool, #{| r})): NamedRowEvaluator[Option[#{| r}]] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional};
        match xs { 
            case eval1 :: rs => {
                let* ans = optional(eval1);
                match ans { 
                    case Some(r1) => {let (_, rac) = ac; getAttributeGroupHelper(rs, (true, r1 <+> rac))}
                    case None => getAttributeGroupHelper(rs, ac)
                }                
            }
            case Nil => let (found, relns) = ac; if (found) return(Some(relns)) else return(None)
        }


}
