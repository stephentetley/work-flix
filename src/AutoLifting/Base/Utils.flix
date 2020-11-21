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

namespace AutoLifting/Base/Utils {
    
    use AssetLib/Common/Osgb36.EastingNorthing;
    use AssetLib/S4/Simple.Classifications;
    use AutoLifting/Base/Datatypes.FixedOrPortable;
    use AutoLifting/Base/Datatypes.FixedOrPortable.{Fixed, Portable};

    ///
    /// Only proper-cases words made solely of letters, it should not proper-case codes like "SAB0665"
    /// 
    def toProperCase1(s: String): Result[String, System.Error] & Impure =
        use Text/Regex/MatchEvaluator.{lift2, getCaptureNamed};
        use Result.flatMap;
        let* patt = Text/Regex/Pattern.compile("^(?<first>\p{IsAlphabetic})(?<rest>\p{IsAlphabetic}*)$");
        let eval = lift2((c,rs) -> String.toUpperCase(c) + String.toLowerCase(rs)
                            , getCaptureNamed("first")
                            , getCaptureNamed("rest")
                            );
        if (Text/Regex.matches(s, patt))
            Text/Regex.rewriteWith(s, patt, eval)
        else 
            Ok(s)


    pub def properCaseEquiName(s: String): Result[String, System.Error] & Impure =
        use Result.{flatMap};
        let words = String.words(s);
        let* xs     = Result.traverse(toProperCase1, words) ;
        Ok(String.unwords(xs))


    pub def liftingFunctionalLocation(root: String, fop: FixedOrPortable): String = match fop { 
        case Fixed => root + "-SMS-LFT-FLT-SYS01"
        case Portable => root + "-SMS-LFT-PRL-SYS01"
    }
        
    pub def suffixDELToName(s: String): String = String.take(34, s) + " (Del)"
        

    pub def formatDateForS4(dt: Time.LocalDate): Result[String, System.Error] = 
        use Result.{flatMap};
        let* fmt = Time/Format/DateFormatter.fromPattern("dd.MM.yyyy");
        let ans = Time/LocalDate.format(dt, fmt);
        Ok(ans)


    pub def cwtToKg(cwt: Float64): Float64 = cwt * 50.80234544f64

    pub def ukTontoKg(ukton: Float64): Float64 = ukton / 0.00098421

    pub def getEastingNorthingClassifications(gridRef: String): Result[Classifications, System.Error] = 
        use Result.{flatMap};
        use AssetLib/Common/Osgb36.{parse, toEastingNorthing};
        use AssetLib/S4/Simple/Classifications.{append, easting, northing};
        let* ngr    = parse(gridRef);
        let* x      = toEastingNorthing(ngr);
        let c1      = easting(x.easting);
        let c2      = northing(x.northing);
        Ok(c1 `append` c2)

    pub def getEastingNorthing(gridRef: String): Result[EastingNorthing, System.Error] = 
        use Result.{flatMap};
        use AssetLib/Common/Osgb36.{parse, toEastingNorthing};
        use AssetLib/S4/Simple/Classifications.{append, easting, northing};
        let* ngr    = parse(gridRef);
        let* ans      = toEastingNorthing(ngr);
        Ok(ans)

}