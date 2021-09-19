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



namespace Hierarchy/Organize {

    use Hierarchy/Loader.{ExportRow};


    pub rel Organization(system: String, subsystem: String, description: String)
    pub rel BoosterSet(num: Int32)

    pub def organize(db: #{BoosterPump, FinalEffPump, 
                            BoosterSet, Organization}): #{Organization} = 
        let rules = #{

            Organization("SYS${pad2(snum + 2)}", "PMP${pad2(pump)}", "${pandi} Booster Pump-${pump}") :-
                BoosterPump(pandi, snum, pump).

            BoosterSet(set) :- 
                BoosterPump(_, set, _).
        };
        solve (db <+> rules) project Organization
        /// query ans1 select (x1, x2, x3) from Organization(x1, x2, x3))

    def pad2(x: Int32): String = String.padLeft(2, '0', ToString.toString(x))

    pub rel BoosterPump(pandi: String, set: Int32, pump: Int32)


    pub def getBoosterPump(): RegexExtractor[#{BoosterPump | r}] & Impure = 
        use Text/Regex/MatchEvaluator.{lift3, getCaptureNamed, getInt32Named};
        { regex   = "WASHWATER PUMPING/\\p{Blank}*(?<pandi>M[0-9]+) BOOSTER SET (?<set>[0-9]) PUMP (?<pump>[0-9])$"
        , evaluator = lift3((x1, x2, x3) -> #{ BoosterPump(x1, x2,x3). }, getCaptureNamed("pandi"), getInt32Named("set"), getInt32Named("pump"))
        }

    pub rel FinalEffPump(pandi: String, pump: Int32)

    pub def getFinalEffPump(): RegexExtractor[#{FinalEffPump | r}] & Impure = 
        use Text/Regex/MatchEvaluator.{lift2, getCaptureNamed, getInt32Named};
        { regex   = "WASHWATER PUMPING/\\p{Blank}*(?<pandi>M[0-9]+) FINAL EFF PUMP (?<pump>[0-9])$"
        , evaluator = lift2((x1, x2) -> #{ FinalEffPump(x1, x2). }, getCaptureNamed("pandi"), getInt32Named("pump"))
        }


    type alias RegexExtractor[r] = 
        { regex: String
        , evaluator: Text/Regex.MatchEvaluator[r]
        }

    pub def extractFromCommonName(extract: RegexExtractor[#{|r}], commonName: String): #{|r} & Impure =  
        let patt   = match Text/Regex/Pattern.compile(extract.regex) {
            case Err(err) => bug!(err)
            case Ok(p1) => p1
        };
        match Text/Regex.evalContains(commonName, patt, extract.evaluator) {
            case Err(_) => #{}
            case Ok(r1) => r1
        }

    pub def extractFromCommonName2(extract: RegexExtractor[a], commonName: String): Option[a] & Impure =  
        let patt   = match Text/Regex/Pattern.compile(extract.regex) {
            case Err(err) => bug!(err)
            case Ok(p1) => p1
        };
        match Text/Regex.evalContains(commonName, patt, extract.evaluator) {
            case Err(_) => None
            case Ok(r1) => Some(r1)
        }

    pub def getEquipmentName(): RegexExtractor[String] & Impure = 
        use Text/Regex/MatchEvaluator.{getCaptureNamed, map};
        { regex   = "WASHWATER PUMPING/(?<name>.+)/EQUIPMENT:"
        , evaluator = map(AssetLib/Base/Utils.properCaseName, getCaptureNamed("name"))
        }

}
