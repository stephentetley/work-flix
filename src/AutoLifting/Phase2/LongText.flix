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

namespace AutoLifting/Phase2/LongText {
    
 
    use AutoLifting/Datatypes.{Phase2WorkItem1, Phase2WorkItem2, AibMemoRow};
    use AutoLifting.ReportMonad;

    pub def loadMemoLookups(path: System.FilePath): ReportMonad[Map[String, String]] =
        use AutoLifting/ReportMonad.{map}; 
        map(buildMemoLookups, 
            AutoLifting/Phase2/AibMemoReader.getAibMemoRows(path)
        )
        
    pub def getLongText(memosMap: Map[String, String], pliReference: String): ReportMonad[Option[String]] = 
        use AutoLifting/ReportMonad.{return};
        return(Map.get(pliReference, memosMap))


    pub def updateLongTexts[r](m: Map[String, String], 
                               xs: List[{pliReference: String | r}]): ReportMonad[List[{longText: Option[String], pliReference: String | r}]] = 
        AutoLifting/ReportMonad.mapM(updateLongText1(m), xs)

    def updateLongText1[r](m: Map[String, String], 
                               x: {pliReference: String | r}): ReportMonad[{longText: Option[String], pliReference: String | r}] = 
        use AutoLifting/ReportMonad.{flatMap, return};
        let oltext  = Map.get(x.pliReference, m);
        return({ +longText = oltext | x })
        

    def buildMemoLookups(xs: List[AibMemoRow]): Map[String, String] = 
        List.foldLeft((ac, x) ->  insertStep(x, ac), Map.empty(), xs)


    def insertStep(x: AibMemoRow, ac: Map[String, String]): Map[String, String] = 
        match makeLongText(x) {
            case Some(text) => Map.insert(x.pliReference, text, ac)
            case None => ac
        }

    def makeLongText(x: AibMemoRow): Option[String] = 
        let memos = x.memo1 :: x.memo2 :: x.memo3 :: x.memo4 :: x.memo5 :: Nil;
        let xs = List.filter(s -> !(String.isEmpty(s)), memos);
        let text = String.intercalate(String.lineSeparator(), xs);
        if (String.isEmpty(text)) None else Some(String.trim(text))


}