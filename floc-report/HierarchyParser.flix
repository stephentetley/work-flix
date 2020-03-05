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
    
type alias DateStamp = { day: Int32, month: Int32, year: Int32 }
type alias FlocRoot = { floc: String, description: String }
type alias FlocRow = { floc: String, description: String, parent: String }
type alias EquiRow = { equiId: String, description: String, floc: String, superordinate: Option[String] }


namespace HierarchyParser {


    def taggedFunctionalLocation(): TextParser.Parser[String] = 
        TextParser.seqRight(
            TextParser.symbol("Functional Location"),
            TextParser.content(34)
        )

    def dateStamp(): TextParser.Parser[DateStamp] = 
        TextParser.pipe3(
            TextParser.seqLeft(TextParser.int32(), TextParser.char('.')),
            TextParser.seqLeft(TextParser.int32(), TextParser.char('.')),
            TextParser.int32(),
            (d,m,y) -> { day = d, month = m, year = y }
        )

    def validFrom(): TextParser.Parser[DateStamp] = 
        TextParser.seqRight(
            TextParser.symbol("Valid From"),
            dateStamp()
        )


    pub def indenting(): TextParser.Parser[String] = 
        TextParser.manyChars(TextParser.oneOf(' ' :: '-' :: '|' :: Nil))

    pub def funcLoc(): TextParser.Parser[String] = 
        TextParser.manyChars2(
            TextParser.upper(),
            TextParser.choice(
                TextParser.upper() :: TextParser.char('-') :: TextParser.digit() :: Nil
            )
        )

    pub def equipmentId(): TextParser.Parser[String] = 
        TextParser.manyChars2(
            TextParser.alt(TextParser.char('$'), TextParser.digit()),
            TextParser.digit()            
        )

    /// Description is always bounded 
    def description(): TextParser.Parser[String] = 
        TextParser.content(41)


    /// Line parsers e.g for FactImport - LinesImport

    pub def funcLocHeaderLine(): TextParser.Parser[(String, DateStamp)] = 
        TextParser.tuple2(
            taggedFunctionalLocation(),
            validFrom()
        )

    pub def descriptionHeaderLine(): TextParser.Parser[String] = 
        TextParser.seqRight(
            TextParser.symbol("Description"),
            TextParser.restOfLine(true)
        )

    pub def flocRootLine(): TextParser.Parser[FlocRoot] = 
        TextParser.pipe2(
            TextParser.seqRight(TextParser.string("  "), TextParser.bounded(funcLoc(), 41)),
            TextParser.restOfLine(true),
            (floc, descr) -> { floc = floc, description = descr }
        )

    pub def flocLine(): TextParser.Parser[FlocRow] = 
        TextParser.pipe3(
            TextParser.seqRight(indenting(), TextParser.bounded(funcLoc(), 41)),
            description(),
            funcLoc(),
            (floc, descr, parent) -> { floc = floc, description = descr, parent = parent }
        )

    pub def equiLine(): TextParser.Parser[EquiRow] = 
        TextParser.bind(
            TextParser.seqRight(indenting(), TextParser.bounded(equipmentId(), 19)), 
            equiId -> TextParser.bind(
                description(),
                descr -> equiLinePart2(equiId, descr)
            ))

    def equiLinePart2(equiId: String, descr: String): TextParser.Parser[EquiRow] = 
        let p1 = 
            TextParser.tuple2(
                TextParser.bounded(funcLoc(), 41), 
                TextParser.fmap(x -> Some(x), equipmentId())
            );
        let p2 = 
            TextParser.tuple2(
                funcLoc(), 
                TextParser.return(None) 
            );
        TextParser.fmap(
            { pair ->
                let (floc1, super1) = pair;
                { equiId = equiId, description = descr, floc = floc1, superordinate = super1 }
            },                
            TextParser.alt(p1, p2)
        )

                

 }