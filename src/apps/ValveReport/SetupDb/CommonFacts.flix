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

namespace ValveReport/SetupDb/CommonFacts {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.SheetReader;
    use SheetIO.DataFormatter;
    use SheetIO.NamedRowEvaluator;

    use ValveReport/SetupDb/TextFact.TextFact;

    /// Todo "Installed From" , "AssetStatus", "Loc.Ref."

    type alias AibBaseRow = 
        { reference: String
        , manufacturer: String
        , model: String
        }



    pub def storeCommonFacts(tableName: String, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{return, flatMap, liftActionResult, map};
        use ValveReport/SetupDb/TextFact.{insertTextFactRows};
        let* xs     = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readAibBaseTable(), src));
        let xss     = List.flatMap(makeTextFacts, xs);
        let* _      = insertTextFactRows(tableName, xss);
        return()

   def readAibBaseTable() : SheetReader[List[AibBaseRow]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetAt, liftAction, namedRowsFrom}; 
        let* s1 = getSheetAt(0); 
        namedRowsFrom(s1, 0, 1, evalAibBaseRow())

    /// TODO - this needs to handle "SAI" rows too, ideally by Option...
    def evalAibBaseRow(): NamedRowEvaluator[AibBaseRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, alt, getStringNamed, 
                getFloat64Named, getStringNamedWithDefault, optional, getStringNamedWithDataFormatter};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use String.{trim};
        ((x1, x2, x3) ->
                { reference         = x1.trim()
                , manufacturer      = x2.trim()
                , model             = x3.trim()
                })
            <&> getStringNamed("Reference")
            <*> getStringNamedWithDefault("Manufacturer", "")
            <*> getCouldBeNumericalNamed("Model")


    def getCouldBeNumericalNamed(label: String): NamedRowEvaluator[String] = 
        use SheetIO/NamedRowEvaluator.{map, alt, getStringNamedWithDefault, getInt64Named};
        alt(getStringNamedWithDefault(label, ""), map(Int64.toString, getInt64Named(label)))
        
    def makeTextFacts(x: AibBaseRow): List[TextFact] = 
        use ValveReport/SetupDb/TextFact.{createNonEmpty};
        let o1 = createNonEmpty(x.reference, "Manufacturer", x.manufacturer);
        let o2 = createNonEmpty(x.reference, "Model", x.model);
        List.filterMap(o -> o, o1 :: o2 :: Nil)

}