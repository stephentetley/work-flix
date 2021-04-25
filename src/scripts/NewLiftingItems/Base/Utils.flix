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

namespace NewLiftingItems/Base/Utils {
    
    use AssetLib/Base/Osgb36.EastingNorthing;
    use AssetLib/S4Lite/CreateNew.Classifications;
    use NewLiftingItems/Base/Datatypes.FixedOrPortable;
    use NewLiftingItems/Base/Datatypes.FixedOrPortable.{Fixed, Portable};




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




    pub def liftingFunctionalLocation(root: String, fop: FixedOrPortable): String = match fop { 
        case Fixed => root + "-SMS-LFT-FLT-SYS01"
        case Portable => root + "-SMS-LFT-PRL-SYS01"
    }
        
    pub def suffixDELToName(s: String): String = String.take(34, s) + " (Del)"
        

    pub def formatDateForS4(dt: Time.LocalDate): Option[String] = 
        use Option.{flatMap};
        let* fmt = Time/Format/DateFormatter.fromPattern("dd.MM.yyyy");
        let ans = Time/LocalDate.format(dt, fmt);
        Some(ans)


    pub def cwtToKg(cwt: Float64): Float64 = cwt * 50.80234544f64

    pub def ukTontoKg(ukton: Float64): Float64 = ukton / 0.00098421

    pub def getEastingNorthingClassifications(gridRef: String): Option[Classifications] = 
        use Option.{flatMap};
        use AssetLib/Base/Osgb36.{parse, toEastingNorthing};
        use AssetLib/S4Lite/CreateNew/Classifications.{append, easting, northing};
        let* ngr    = parse(gridRef);
        let* x      = toEastingNorthing(ngr);
        let c1      = easting(x.easting);
        let c2      = northing(x.northing);
        Some(c1 `append` c2)

    pub def getEastingNorthing(gridRef: String): Option[EastingNorthing] = 
        use Option.{flatMap};
        use AssetLib/Base/Osgb36.{parse, toEastingNorthing};
        use AssetLib/S4Lite/CreateNew/Classifications.{append, easting, northing};
        let* ngr    = parse(gridRef);
        let* ans      = toEastingNorthing(ngr);
        Some(ans)

}