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


namespace AssetLib/Base/S4 {

    pub enum Floc(List[String])

    instance ToString[Floc] { 
        pub def toString(x: Floc): String = 
            let Floc(x1) = x;
            String.intercalate("-", x1)
    }

    instance FromString[Floc] { 
        pub def fromString(x: String): Option[Floc] = 
            AssetLib/Base/S4/Floc.floc(x) |> Result.toOption
    }

    instance Eq[Floc] { 
        pub def eq(x: Floc, y: Floc): Bool = 
            let Floc(x1) = x;
            let Floc(y1) = y;
            x1 == y1
    }

    instance Order[Floc] {
        pub def compare(x: Floc, y: Floc): Comparison = Order.compare(ToString.toString(x), ToString.toString(y))
    }

    instance Hash[Floc] {
        pub def hash(x: Floc): Int32 = Hash.hash(ToString.toString(x))
    }

}    

namespace AssetLib/Base/S4/Floc {

    use AssetLib/Base/S4.Floc;
    use AssetLib/Base/S4.Floc.{Floc};

    /// `s` cannot be empty.
    pub def floc(s: String): Result[Floc, String] = 
        if (String.isEmpty(s))
            Err("Err: Empty Floc")
        else
            Ok(Floc(String.splitOn({substr = "-"}, s)))

    /// Build an invalid floc if `s` is empty...
    pub def floc1(s: String): Floc = 
        if (String.isEmpty(s))
            Floc("???" :: Nil)
        else
            Floc(String.splitOn({substr = "-"}, s))


    pub def equals(x: Floc, y: Floc): Bool = 
        let Floc(xs) = x;
        let Floc(ys) = y;
        String.intercalate("-", xs) == String.intercalate("-", ys)



    pub def snoc(x: Floc, s: String): Floc = 
        let Floc(x1) = x;
        let ys = String.splitOn({substr = "-"}, s);
        Floc(x1 ::: ys)
    

    pub def toString(x: Floc): String = 
        let Floc(xs1) = x;
        String.intercalate("-", xs1)

    /// level
    pub def level(x: Floc): Int32 = 
        let Floc(xs1) = x;
        List.length(xs1)


    /// suffix
    pub def getSuffix(x: Floc): Option[String] = 
        let Floc(xs1) = x;
        List.last(xs1)


    /// Prefix
    pub def getSiteCode(x: Floc): Option[String] = 
        let Floc(xs1) = x;
        List.head(xs1)


    /// 
    pub def getFunctionCode(x: Floc): Option[String] =
        let Floc(xs1) = x;
        at(1, xs1)
        
    pub def getProcessGroupCode(x: Floc): Option[String] =
        let Floc(xs1) = x;
        at(2, xs1)
    
    pub def getProcessCode(x: Floc): Option[String] =
        let Floc(xs1) = x;
        at(3, xs1)
    
    pub def getSystemCode(x: Floc): Option[String] =
        let Floc(xs1) = x;
        at(4, xs1)
    
    pub def getSystemIndex(x: Floc): Option[Int32] =
        use Option.{flatMap};
        use Text/RegexEval/MatchEvaluator.{getInt32At};
        region r {
            let* s = getSystemCode(x);
            let* patt = Text/Regex/Pattern.compile("SYS(\\d{2})") |> Result.toOption;
            Result.toOption(Text/RegexEval/Regex.matchAll(r, getInt32At(0), patt, s))
        }
        
    pub def getSubsystemCode(x: Floc): Option[String] =
        let Floc(xs1) = x;
        at(5, xs1)
    
    pub def getSubsystemTag(x: Floc): Option[String] =
        use Option.{flatMap};
        use Text/RegexEval/MatchEvaluator.{getCaptureAt};
        region r {
            let* s = getSubsystemCode(x);
            let* patt = Text/Regex/Pattern.compile("(\\p{Upper}{3})\\d{2}") |> Result.toOption;
            Result.toOption(Text/RegexEval/Regex.matchAll(r, getCaptureAt(0), patt, s))
        }
    
    pub def getSubsystemIndex(x: Floc): Option[Int32] =
        use Option.{flatMap};
        region r {
            use Text/RegexEval/MatchEvaluator.{getInt32At};        
            let* s = getSubsystemCode(x);
            let* patt = Text/Regex/Pattern.compile("\\p{Upper}{3}(\\d{2})") |> Result.toOption;
            Result.toOption(Text/RegexEval/Regex.matchAll(r, getInt32At(0), patt, s))
        }

    def at(i: Int32, xs: List[a]): Option[a] = match (i, xs) {
        case (0, x :: _) => Some(x)
        case (p, _ :: rs) if p > 0 => at(p - 1, rs)
        case _ => None
    }


    /// parent
    pub def parent(x: Floc): Option[Floc] = 
        let Floc(xs1) = x;
        List.init(xs1) |> Option.map(Floc)

    /// Only approprite for `level(x) < 5`.
    pub def objectType(x: Floc): Option[String] = match level(x) {
        case x1 if x1 == 1 => Some("SITE")
        case x1 if x1 > 1 and x1 < 5 => {let Floc(xs) = x; List.last(xs)}
        case _ => None
    }

    /// "unsafe" version of parent
    pub def pop(x: Floc): Floc = 
        let Floc(xs1) = x;
        match List.init(xs1) {
            case Some(xs) => Floc(xs)
            case None => Floc(Nil)
        } 

}
