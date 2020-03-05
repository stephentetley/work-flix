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

/// match Windows `dir` output


pub rel Existing(name: String, batch: String)
pub rel SWS(name: String)

pub rel Todo(name: String)
pub rel Done(name: String)

namespace FileMatch {

    ///
    /// Build a string from the seed value `x` applying the function `f` until `f` returns `None`.
    ///
    pub def unfold(f: b -> Option[(Char, b)], x: b) : String =
        unfoldHelper(f, x) |> List.toString

    ///
    /// Helper function for `unfold`.
    ///
    def unfoldHelper(f: b -> Option[(Char, b)], x: b) : List[Char] = match f(x) {
        case None => Nil
        case Some(c, st1) => c :: unfoldHelper(f, st1)
    }

    pub def commonPrefix(s: Str, t: Str): Str = 
        let len = Int32.min(String.length(s), String.length(t));
        let f = i -> 
            if (i < len && String.charAt(i, s) == String.charAt(i, t))
                Some(String.charAt(i, s), i+1)
            else None;
        unfold(f, 0)

    pub def isPrefixOf(sub: String, s: String): Bool = sub == commonPrefix(sub, s)

    def fail1(msg: String): reln & Impure = { Console.printLine(msg);  #{ } }

    pub def applyParser(p: TextParser.Parser[a], line: TextLine): LineResult[a] = 
        LinesImport.applyRes(TextParser.run(p), line)

    def parseFolder(): TextParser.Parser[Option[Folder]] = 
        TextParser.alt( 
            TextParser.fmap(Some, DirListing.pFolder()),
            TextParser.fmap(_ -> None, DirListing.ignoreLine())
        )



    /// Exposed for testing
    pub def parseSWS[r](): TextParser.Parser[Option[#{ SWS | r }]] = 
        let mk = { d -> SWS(d.name). };
        TextParser.fmap(Option.map(mk), parseFolder())
        

    def getSWSLine[r](line: TextLine): LineResult[Option[ #{ SWS | r } ]] = 
        applyParser(parseSWS(), line) 


    pub def importSWS[r](path: String, cs: Charset): #{ SWS | r } & Impure =
        match LinesImport.newLinesSource(path, cs) {
            case Err(msg) => fail1(msg)
            case Ok(src) => 
                match LinesImport.choose(getSWSLine, src) {
                    case Err(msg) => fail1(msg)
                    case Ok(relns) => solve relns
                }
        }

    /// Exposed for testing
    pub def parseExisting[r](batchName: String): TextParser.Parser[Option[ #{ Existing | r } ]] = 
        let mk = { d -> Existing(d.name, batchName). };
        TextParser.fmap(Option.map(mk), parseFolder())
        

    def getExistingLine[r](batchName: String, line: TextLine): LineResult[Option[ #{ Existing | r } ]] = 
        applyParser(parseExisting(batchName), line) 

    pub def importBatch[r](path: String, cs: Charset, batchName: String ): #{ Existing | r } & Impure =
        match LinesImport.newLinesSource(path, cs) {
            case Err(msg) => fail1(msg)
            case Ok(src) => 
                match LinesImport.choose(getExistingLine(batchName), src) {
                    case Err(msg) => fail1(msg)
                    case Ok(relns) => solve relns
                }
        }

    pub def fileMatchRules[r](): #{ SWS, Existing, Done, Todo | r } =
        let isPrefix = (x,y)  -> FileMatch.isPrefixOf(x, y);
        #{ 
            Done(x) :- SWS(x), if isPrefix(x,y), Existing(y, _).
            Todo(x) :- SWS(x), not Done(x).
        }
        

}