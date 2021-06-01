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

namespace AssetLib/AibFacts/Utils {
    
    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/Base/Osgb36.{EastingNorthing};

    pub def readAibFacts(eval: NamedRowEvaluator[#{| r}],
                        allowEmpty: Bool, 
                        sheetName: String, 
                        path: System.FilePath): Result[#{| r}, String] & Impure =
        use SheetIO/NamedRowEvaluator.{withDefault};
        let eval1 = if (allowEmpty) withDefault(eval, #{}) else eval;
        SheetIO/SheetReader.runXlsx(readAibSheet(eval1, sheetName), path)
        

    pub def readAibSheet(eval: NamedRowEvaluator[#{| r}], sheetName: String): SheetReader[#{| r}] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};         
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, eval);
        let relns   = List.foldLeft((ac, x) -> ac <+> x, #{}, xs);
        return(relns)

    pub def getStringValuedFact(columnName: String, f: (String, String) -> ans): NamedRowEvaluator[ans] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getNonEmptyContentNamed};  
        let* x1     = getNonEmptyContentNamed("Reference");
        let* x2     = getNonEmptyContentNamed(columnName);
        return(f(x1, x2))

    pub def getIntValuedFact(columnName: String, f: (String, Int32) -> ans): NamedRowEvaluator[ans] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getNonEmptyContentNamed, getInt32Named};  
        let* x1     = getNonEmptyContentNamed("Reference");
        let* x2     = getInt32Named(columnName);
        return(f(x1, x2))


    pub def getFloatValuedFact(columnName: String, f: (String, Float64) -> ans): NamedRowEvaluator[ans] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getNonEmptyContentNamed, getFloat64Named};  
        let* x1     = getNonEmptyContentNamed("Reference");
        let* x2     = getFloat64Named(columnName);
        return(f(x1, x2))

    ///
    /// Only proper-cases words made solely of letters, it should not proper-case codes like "SAB0665"
    /// 
    pub def properCaseEquiName(s: String): Option[String] =
        use Option.{flatMap};
        let words = String.words(s);
        let* xs = Option.traverse(toProperCase1, words) as & Pure;
        Some(String.unwords(xs))

    ///
    /// Only proper-cases words made solely of letters, it should not proper-case codes like "SAB0665"
    /// 
    def toProperCase1(s: String): Option[String] & Impure =
        use Text/Regex/MatchEvaluator.{lift2, getCaptureNamed};
        use Option.flatMap;
        let* patt = Text/Regex/Pattern.compile("^(?<first>\p{IsAlphabetic})(?<rest>\p{IsAlphabetic}*)$");
        let eval = lift2((c,rs) -> String.toUpperCase(c) + String.toLowerCase(rs)
                            , getCaptureNamed("first")
                            , getCaptureNamed("rest")
                            );
        match Text/Regex.rewriteWith(s, patt, eval) { 
            case Ok(s1) if s1 != "" => Some(s1)
            case _  => Some(s)
        }

        
    pub def suffixDELToName(s: String): String = String.take(34, s) + " (Del)"
        

    pub def formatDateForS4(dt: Time.LocalDate): Option[String] = 
        use Option.{flatMap};
        let* fmt = Time/Format/DateFormatter.ofPattern("dd.MM.yyyy");
        let ans = Time/LocalDate.format(dt, fmt);
        Some(ans)


    pub def cwtToKg(cwt: Float64): Float64 = cwt * 50.80234544f64

    pub def ukTontoKg(ukton: Float64): Float64 = ukton / 0.00098421



}