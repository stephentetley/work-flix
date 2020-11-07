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
    
    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AutoLifting/Common/Datatypes.{Phase2WorkItem1, Phase2WorkItem2, AibMemoRow};
    use AutoLifting/Common.ReportMonad;



    pub def getLongText(memosMap: Map[String, String], pliReference: String): ReportMonad[Option[String]] = 
        use AutoLifting/Common/ReportMonad.{return};
        return(Map.get(pliReference, memosMap))


    /// AIB reports are apparently limited to 166 rows, we might have to read multiple files.
    pub def loadMemoLookups(paths: List[System.FilePath]): ReportMonad[Map[String, String]] =
        use AutoLifting/Common/ReportMonad.{foldM, map}; 
        foldM((ac, x) -> map(buildMemoLookups(ac), getAibMemoRows(x)), Map.empty(), paths)

    def buildMemoLookups(start: Map[String, String], xs: List[AibMemoRow]): Map[String, String] = 
        List.foldLeft((ac, x) ->  insertStep(x, ac), start, xs)


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



    /// Must be a *.xlsx (OO-XML) file.
    def getAibMemoRows(path: System.FilePath): ReportMonad[List[AibMemoRow]] =
        use AutoLifting/Common/ReportMonad.{liftActionResult};
        liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readAibMemoRows(), path))
        

    def readAibMemoRows() : SheetReader[List[AibMemoRow]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetAt, namedRowsFrom}; 
        let* s1 = getSheetAt(0); 
        namedRowsFrom(s1, 0, 1, evalAibMemoRow())

    def evalAibMemoRow(): NamedRowEvaluator[AibMemoRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getStringNamed, getStringNamedWithDefault};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6) -> 
                { pliReference  = String.trim(x1)
                , memo1         = String.trim(x2)
                , memo2         = String.trim(x3)
                , memo3         = String.trim(x4)
                , memo4         = String.trim(x5)
                , memo5         = String.trim(x6)
                })
            <&> getStringNamed("Reference")
            <*> getStringNamedWithDefault("Memo Line 1", "")
            <*> getStringNamedWithDefault("Memo Line 2", "")
            <*> getStringNamedWithDefault("Memo Line 3", "")
            <*> getStringNamedWithDefault("Memo Line 4", "")
            <*> getStringNamedWithDefault("Memo Line 5", "")


}