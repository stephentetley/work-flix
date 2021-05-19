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

namespace AssetLib/FileIO/PDT {

    use SheetIO.SheetReader;

    pub opaque type PDTParser[a] = (SheetIO.Sheet, Int32) -> SheetReader[(Int32, a)]

}

namespace AssetLib/FileIO/PDT/PDTParser {

    use SheetIO.Sheet;
    use SheetIO.SheetReader;
    use SheetIO.RowEvaluator;

    use AssetLib/FileIO/PDT.PDTParser;
    use AssetLib/FileIO/PDT.PDTParser.{PDTParser};

    /// No headers - read all of the datasheet into a Map[String, String]
    pub def parseFile(parser: PDTParser[a], sheetName: String, path: System.FilePath): Result[a, String] & Impure = 
        SheetIO/SheetReader.runXlsx(readPDT(parser, sheetName), path)

    def readPDT(parser: PDTParser[a], sheetName: String): SheetReader[a] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, foldAllRows};      
        let PDTParser(p1) = parser;
        let* sheet      = getSheetNamed(sheetName);
        let* (_, ans)   = p1(sheet, 0);
        return(ans)

    pub def return(x: a): PDTParser[a] = 
        PDTParser((_, ix) -> SheetIO/SheetReader.return((ix, x)))

    def apply1(x: PDTParser[a], sheet: Sheet, ix: Int32): SheetReader[(Int32, a)] =
        let PDTParser(f) = x;
        f(sheet, ix)

    def mapFst(f: a -> c & ef, xy: (a, b)): (c, b) & ef = 
        let (a, b) = xy;
        (f(a), b)

    def mapSnd(f: b -> c & ef, xy: (a, b)): (a, c) & ef = 
        let (a, b) = xy;
        (a, f(b))


    pub def throwError(msg: String): PDTParser[a] =
        PDTParser((_, _) -> SheetIO/SheetReader.throwError(msg))

    pub def swapError(ma: PDTParser[a], msg: String): PDTParser[a] =
        PDTParser((sheet, ix) ->
            SheetIO/SheetReader.swapError(apply1(ma, sheet, ix), msg)
        )

    /// Needs to allow allow effects (e.g create / access arrays)
    pub def map(fn: a -> b & ef, ma: PDTParser[a]): PDTParser[b] = 
        PDTParser((sheet, ix) ->
            SheetIO/SheetReader.map(mapSnd(fn), apply1(ma, sheet, ix))
        )

    pub def ap(mf: PDTParser[a -> b & ef], ma: PDTParser[a]): PDTParser[b] = 
        let* f  = mf;
        let* a  = ma;
        liftAction(_ -> f(a) as & Impure)

    pub def seqLeft(pa: PDTParser[a], pb: PDTParser[b]): PDTParser[a] = 
        let* a = pa;
        let* _ = pb;
        return(a)

    pub def seqRight(pa: PDTParser[a], pb: PDTParser[b]): PDTParser[b] = 
        let* _ = pa;
        let* b = pb;
        return(b)

    pub def bind(ma: PDTParser[a], fn: a -> PDTParser[b]): PDTParser[b] = 
        PDTParser((sheet, ix) ->
            SheetIO/SheetReader.bind(
                apply1(ma, sheet, ix),
                xy -> {let (ix1, a1) = xy; apply1(fn(a1), sheet, ix1)}
            )
        )

    pub def flatMap(fn: a -> PDTParser[b], ma: PDTParser[a]): PDTParser[b] = bind(ma, fn)

    pub def liftAction(fn: Unit ~> a): PDTParser[a] = 
        PDTParser((_, ix) -> 
            SheetIO/SheetReader.liftAction(_ -> {let a = fn(); (ix, a)})
        )

    pub def <*(pa: PDTParser[a], pb: PDTParser[b]): PDTParser[a] = seqLeft(pa, pb) 

    pub def *>(pa: PDTParser[a], pb: PDTParser[b]): PDTParser[b] = seqRight(pa, pb)


    pub def setPosition(ix: Int32): PDTParser[Unit] = 
        PDTParser((_, _) -> SheetIO/SheetReader.return((ix, ())))

    pub def getPosition(): PDTParser[Int32] = 
        PDTParser((_, ix) -> SheetIO/SheetReader.return((ix, ix)))

    pub def incPosition(): PDTParser[Unit] = 
        PDTParser((_, ix) -> SheetIO/SheetReader.return((ix + 1, ())))

    /// Note - SheetReader has too much power (should it be changed?), it is really "WorkbookReader" and sees 
    /// more than the current sheet
    def liftSheetReader(f: Sheet -> SheetReader[a]): PDTParser[a] = 
        PDTParser((sheet, ix) -> 
            SheetIO/SheetReader.map(x -> (ix, x), f(sheet))
        )


    pub def getLastRowNum(): PDTParser[Int32] = 
        liftSheetReader(SheetIO/SheetReader.getLastRowNum)

    pub def evalRow(eval: RowEvaluator[a]): PDTParser[a] =
        use SheetIO/SheetReader.{flatMap, return, throwError, getRowAt, getLastRowNum, rowEval};
        PDTParser((sheet, ix) -> {
            let* end = getLastRowNum(sheet);
            if (ix > end) 
                throwError("evalRow - eof")
            else {
                let* row = getRowAt(sheet, ix);
                let* ans = rowEval(row, eval);
                return((ix + 1, ans))
            }
        })

    pub def isEof(): PDTParser[Bool] =  
        use SheetIO/SheetReader.{flatMap, return, getLastRowNum};
        PDTParser((sheet, ix) -> {
            let* end = getLastRowNum(sheet);
            if (ix > end) 
                return((ix, true))
            else 
                return((ix, false))
        })

    pub def lookahead(p: PDTParser[a]): PDTParser[a] =        
        PDTParser((sheet, ix) ->
            SheetIO/SheetReader.map(mapFst(_ -> ix), apply1(p, sheet, ix))
        )

    pub def result(p: PDTParser[a]): PDTParser[Result[a, String]] = 
        use SheetIO/SheetReader.{flatMap, return, result};
        PDTParser((sheet, ix) -> {
            let* ans = result(apply1(p, sheet, ix));
            match ans { 
                case Ok((ix2, a1)) => return((ix2, Ok(a1)))
                case Err(msg) => return((ix, Err(msg)))
            }
        })

    pub def optional(p: PDTParser[a]): PDTParser[Option[a]] = 
        use SheetIO/SheetReader.{flatMap, return, optional};
        PDTParser((sheet, ix) -> {
            let* ans = optional(apply1(p, sheet, ix));
            match ans { 
                case Some((ix2, a1)) => return((ix2, Some(a1)))
                case None => return((ix, None))
            }
        })


    pub def literal(ix: Int32, s: String): RowEvaluator[String] = 
        use SheetIO/RowEvaluator.{flatMap, return, getContentAt, throwError};
        let* s1 = getContentAt(ix);
        if (s1 == s)
            return(s)
        else 
            throwError("literal not matched: demands '${s}' saw '${s1}'")

    pub def content(ix: Int32): RowEvaluator[String] = SheetIO/RowEvaluator.getContentAt(ix)
        


    /// Not CPS... optional backtracks on fail so must increase row position manually...
    pub def skipRowsTill(eval: RowEvaluator[a]): PDTParser[a] with ToString[a] = 
        let* end    = isEof();
        if (end)
            throwError("skipRowsTill eof")
        else {
            let* ans = optional(evalRow(eval));
            match ans {
                case Some(a1) => return(a1)
                case None => seqRight(incPosition(), skipRowsTill(eval))
            }
        }



}
