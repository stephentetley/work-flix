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

    def mapSnd(f: a -> b & ef, xy: (c, a)): (c, b) & ef = 
        let (c, a) = xy;
        (c, f(a))


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

    pub def seqLeft(ma: PDTParser[a], mb: PDTParser[b]): PDTParser[a] = 
        PDTParser((sheet, ix) ->
            SheetIO/SheetReader.seqLeft(apply1(ma, sheet, ix), apply1(mb, sheet, ix))
        )

    pub def seqRight(ma: PDTParser[a], mb: PDTParser[b]): PDTParser[b] = 
        PDTParser((sheet, ix) ->
            SheetIO/SheetReader.seqRight(apply1(ma, sheet, ix), apply1(mb, sheet, ix))
        )

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

    /// Note - SheetReader has too much power (should it be changed?), it is really "WorkbookReader" and sees 
    /// more than the current sheet
    /// def liftSheetReader(ma: SheetReader[a]): PDTParser[a] = 
    ///     PDTParser((_, ix) -> 
    ///         SheetIO/SheetReader.map(x -> (ix, x), ma)
    ///     )

    pub def readRow(eval: RowEvaluator[a]): PDTParser[a] =
        use SheetIO/SheetReader.{flatMap, return, getRowAt, rowEval};
        PDTParser((sheet, ix) -> {
            let* row = getRowAt(sheet, ix);
            let* ans = rowEval(row, eval);
            return((ix + 1, ans))
        })

}
