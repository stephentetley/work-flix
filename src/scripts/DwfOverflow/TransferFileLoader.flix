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

namespace DwfOverflow/Rules/TransferFileLoader {
    
    use Text/Regex.MatchEvaluator;

    use AssetLib/S4/FileIO/TransferFile.RowEvaluator;
    use DwfOverflow/Relations.{ExistingFloc, FreeSettlementSysIndex};

    /// General flocs (levels 2-4).
    /// "RIL01-WWT-SOF-FLS" becomes `ExistingFloc("RIL01", "WWT-SOF-FLS")`
    pub def readFlocTransferFile[r](src: System.FilePath): Result[#{ExistingFloc | r}, String] & Impure = 
        use AssetLib/S4/FileIO/TransferFile/Evaluate.{readAllRows};
        let step = (ac, x) -> {
            match splitName(x) { 
                case Some((s, s1)) => {let x1 = #{ ExistingFloc(s, s1). }; x1 <+> ac }
                case None => ac
            }            
        };
        Result.map(xs -> List.foldLeft(step, #{}, xs), readAllRows(evalFuncLocRow(), src))

    def evalFuncLocRow(): RowEvaluator[String] = 
        AssetLib/S4/FileIO/TransferFile/RowEvaluator.getStringNamed("FUNCLOC")

    def splitName(s: String): Option[(String, String)] = 
        match String.splitOn(s, "-") {
            case s1 :: rs => Some((s1, String.intercalate("-", rs)))
            case _ => None
        }

    pub def readSysFlocTransferFile[r](src: System.FilePath): Result[#{FreeSettlementSysIndex | r}, String] & Impure = 
        use Result.{flatMap};
        let* xs     = AssetLib/S4/FileIO/TransferFile/Evaluate.readAllRows(evalFuncLocRow(), src);
        let* splits = Option.toOk(Option.traverse(splitName, xs), "malformed splits");
        let groups  = List.groupBy((x,y) -> fst(x) == fst(y), splits);
        let gaps    = List.filterMap(findGap, groups);
        let step    = (ac, p) -> {let (s, num) = p; let x1 = #{ FreeSettlementSysIndex(s, num). }; x1 <+> ac };
        let relns   = List.foldLeft((step), #{}, gaps);
        Ok(relns)
        
    def findGap(xs: List[(String, String)]): Option[(String, Int)] & Impure = 
        use Option.{flatMap};
        use Text/Regex.{evalContains};
        use Text/Regex/MatchEvaluator.{getInt32At};
        let* patt = Text/Regex/Pattern.compile("SYS(\d+2))");
        let* (site, suffixes) = unpair(xs);
        let* ixs = Result.toOption(Result.traverse(s -> evalContains(s, patt, getInt32At(0)), suffixes));
        let ix1 = firstHole(1, ixs);
        Some((site, ix1))

    def unpair(xs: List[(String, String)]): Option[(String, List[String])] = match xs {
        case x1 :: rs => { let (site, suffix1) = x1; Some((site, suffix1 :: List.map(snd, rs))) }
        case _ => None
    }
        
    def firstHole(n: Int32, ixs: List[Int32]): Int32 = match ixs {
        case ix :: _ if n < ix => n
        case ix :: rs if n == ix => firstHole(n+1, rs)
        case ix :: rs if n >= ix => firstHole(n, rs)        /// This shouldnt occur as ixs is ordered
        case Nil => n
    }
    
}