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

namespace S4DownloadParser {

    pub def makeIso8601DateTime(ts: String, ds: String): String = 
        String.slice(0,4,ts) + "-" + String.slice(4,6,ts) + "-" + String.slice(6,8,ts) 
            + "T" 
            + String.slice(0,2,ds) + ":" + String.slice(2,4,ts) + ":" + String.slice(4,6,ts) 

    def asterisk(): TextParser.Parser[Char] = 
        TextParser.rightPadded(TextParser.char('*'))

    def nameValue(name: String, pValue: TextParser.Parser[a]): TextParser.Parser[a] = 
        TextParser.pipe4(
            TextParser.string(name),
            TextParser.char(':'),
            TextParser.optional(TextParser.space()),
            pValue,
            (_,_,_,z) -> z
        )

    def restOfLine(): TextParser.Parser[String] = 
        TextParser.restOfLine(false)

    
    def singleLine(p: TextParser.Parser[a]): TextParser.Parser[a] = 
        TextParser.seqLeft(
            p, TextParser.endOfLine()
        )

    pub def download(): TextParser.Parser[String] =
        TextParser.seqRight(asterisk(), TextParser.string("Download"))

    pub def dataModel(): TextParser.Parser[String] = 
        TextParser.seqRight(
            asterisk(),
            nameValue("Data Model", restOfLine())
        )

    pub def entityType(): TextParser.Parser[String] = 
        TextParser.seqRight(
            asterisk(),
            nameValue("Entity Type", restOfLine())
        )

    pub def variant(): TextParser.Parser[String] = 
        TextParser.seqRight(
            asterisk(),
            nameValue("Variant", restOfLine())
        )
    
    pub def user(): TextParser.Parser[String] = 
        TextParser.seqRight(
            asterisk(),
            nameValue("User", restOfLine())
        )

    pub def dateTime(): TextParser.Parser[(String, String)] = 
        TextParser.pipe4(
            asterisk(),
            nameValue("Date", TextParser.digits()),
            TextParser.padded(TextParser.char('/')),
            nameValue("Time", TextParser.digits()),
            (_, d, _, t) -> (d,t)
        )

    pub def selectionHeader(): TextParser.Parser[Unit] = 
        TextParser.seqRight(
            asterisk(),
            nameValue("Selection", restOfLine())
        ) |> TextParser.ignore

    pub def selectionLine(): TextParser.Parser[String] = 
        TextParser.seqRight(
            TextParser.string("* "),
            restOfLine()
        )

    pub def selection(): TextParser.Parser[List[String]] = 
        TextParser.seqRight(
            singleLine(selectionHeader()),
            TextParser.many(singleLine(selectionLine()))
        ) |> TextParser.swapError("selection")

    def columnName(): TextParser.Parser[String] = 
        TextParser.manyChars2(
            TextParser.upper(),
            TextParser.choice(TextParser.upper() :: TextParser.char('_') :: TextParser.digit() :: Nil)
        ) |> TextParser.swapError("columnName")

    pub def columnHeaders(): TextParser.Parser[List[String]] = 
        TextParser.seqRight(
            asterisk(),
            TextParser.sepBy(columnName(), TextParser.tab())
        ) |> TextParser.nestError("columnHeaders") 

    def cellValue(): TextParser.Parser[String] = 
        TextParser.manyChars(TextParser.noneOf('\t' :: '\r' :: '\n' :: Nil))
            |> TextParser.swapError("cellValue")

    pub def valueRow(): TextParser.Parser[List[String]] = 
        TextParser.endBy(cellValue(), TextParser.tab())
            |> TextParser.swapError("valueRow")

    pub opaque type DownloadHeader = 
        { datamodel: String
        , entitytype: String
        , variant: String 
        , username: String 
        , datetime: String
        }


    pub def pHeader(): TextParser.Parser[DownloadHeader] = 
        TextParser.pipe6(
            singleLine(download()),
            singleLine(dataModel()),
            singleLine(entityType()),
            singleLine(variant()),
            singleLine(user()),
            singleLine(dateTime()),
            (_,a1,a2,a3,a4,a5) -> {
                let (d,t) = a5;
                let timestamp = makeIso8601DateTime(d,t); 
                DownloadHeader({ datamodel = a1, entitytype = a2, variant = a3, username = a4, datetime = timestamp })
            }
        )
    
    pub opaque type DownloadFile = 
        { header: DownloadHeader 
        , selections: List[String]
        , columnheaders: List[String]
        , rows: List[List[String]]
        }

    pub def pDownload(): TextParser.Parser[DownloadFile] = 
        TextParser.pipe4(
            pHeader(),
            selection(),
            singleLine(columnHeaders()),
            TextParser.manyTill(singleLine(valueRow()), TextParser.endOfInput()),
            (a1,a2,a3,a4) -> {
                DownloadFile({ header = a1, selections = a2,
                                columnheaders = a3, rows = a4 })
            }
        )

}