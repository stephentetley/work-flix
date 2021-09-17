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


namespace AssetLib/Base/Utils {

    ///
    /// Only proper-cases words made solely of letters, it should not proper-case codes like "SAB0665"
    ///
    pub def properCaseName(s: String): String =
        use Option.{flatMap};
        let toks = tokenize(s);
        let xs = Option.traverse(toProperCase1, toks) as & Pure;
        Option.getWithDefault(xs, s :: Nil) |> String.flatten |> String.trim


    pub def tokenize(s: String): List[String] = 
        let patt = match Text/Regex/Pattern.compile("\\p{Space}+|\\-|/") {
            case Ok(p1) => p1
            case Err(msg) => bug!(msg)
        };
        tokenizeWordHelper(patt, s, ks -> ks)

    def tokenizeWordHelper(patt: Text/Regex.Pattern, s: String, k: List[String] -> List[String]): List[String] = 
        let (word, rs) = Text/Regex.breakOnLeft(patt, s); 
        if (String.isEmpty(rs)) 
            k(word :: Nil) 
        else
            tokenizeSpaceHelper(patt, rs, ks -> k(word :: ks))

    def tokenizeSpaceHelper(patt: Text/Regex.Pattern, s: String, k: List[String] -> List[String]): List[String] = 
        let (word, rs) = Text/Regex.breakAfterLeft(patt, s); 
        if (String.isEmpty(rs)) 
            k(word :: Nil) 
        else
            tokenizeWordHelper(patt, rs, ks -> k(word :: ks))

    ///
    /// Only proper-cases words made solely of letters, it should not proper-case codes like "SAB0665"
    /// 
    def toProperCase1(s: String): Option[String] & Impure =
        use Text/Regex/MatchEvaluator.{lift2, getCaptureNamed};
        use Option.flatMap;
        let* patt = Text/Regex/Pattern.compile("^(?<first>\\p{IsAlphabetic})(?<rest>\\p{IsAlphabetic}*)$") |> Result.toOption;
        let eval = lift2((c,rs) -> String.toUpperCase(c) + String.toLowerCase(rs)
                            , getCaptureNamed("first")
                            , getCaptureNamed("rest")
                            );
        match Text/Regex.rewriteWith(s, patt, eval) { 
            case Ok(s1) if s1 != "" => Some(s1)
            case _  => Some(s)
        }



    pub def sepBy(input: String, sep: String): Array[String] & Impure =
        use Text/Regex.{split};
        use Text/Regex/Pattern.{compile, quote};
        match compile(quote(sep)) {
            case Ok(patt) => split(input, patt)
            case Err(_)   => Array.new(input, 1)
        }

    pub def sepByPattern(input: String, sep: Text/Regex.Pattern): Array[String] & Impure =
        use Text/Regex.{split};
        split(input, sep)

    /// Input starts with sep...
    pub def leadingSepBy(input: String, sep: String): Array[String] & Impure =
        use Text/Regex.{split};
        use Text/Regex/Pattern.{compile, quote};
        match compile(quote(sep)) {
            case Ok(patt) => split(input, patt) |> Array.dropLeft(1)
            case Err(_)   => Array.new("", 0)
        }

    /// Input starts with sep...
    pub def leadingSepByPattern(input: String, sep: Text/Regex.Pattern): Array[String] & Impure =
        use Text/Regex.{split};
        split(input, sep) |> Array.dropLeft(1)

}
