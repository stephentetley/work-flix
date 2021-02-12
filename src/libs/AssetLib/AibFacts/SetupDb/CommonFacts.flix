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

namespace AssetLib/AibFacts/SetupDb/CommonFacts {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.SheetReader;
    use SheetIO.DataFormatter;
    use SheetIO.NamedRowEvaluator;

    use AssetLib/AibFacts/SetupDb/TextFact.TextFact;

    /// Todo "Installed From" , "AssetStatus", "Loc.Ref."

    type alias AibBaseRow = 
        { reference: String
        , commonName: String
        , manufacturer: String
        , model: String
        , installedFrom: Time.LocalDateTime
        , assetStatus: String
        , locRef: String
        }



    pub def storeCommonFacts(textTableName: String, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{return, flatMap, liftActionResult, map};
        use AssetLib/AibFacts/SetupDb/TextFact.{insertTextFactRows};
        let* xs     = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readAibBaseTable(), src));
        let xss     = List.flatMap(makeTextFacts, xs);
        let* _      = insertTextFactRows(textTableName, xss);
        return()

   def readAibBaseTable() : SheetReader[List[AibBaseRow]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetAt, liftAction, namedRowsFrom}; 
        let* s1 = getSheetAt(0); 
        namedRowsFrom(s1, 0, 1, evalAibBaseRow())

 
    def evalAibBaseRow(): NamedRowEvaluator[AibBaseRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed, getLocalDateTimeNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use String.{trim};
        ((x1, x2, x3, x4, x5, x6, x7) ->
                { reference         = x1.trim()
                , commonName        = x2.trim()
                , manufacturer      = x3.trim()
                , model             = x4.trim()
                , installedFrom     = x5
                , assetStatus       = x6
                , locRef            = x7
                })
            <&> getContentNamed("Reference")
            <*> getContentNamed("Common Name")
            <*> getContentNamed("Manufacturer")
            <*> getContentNamed("Model")
            <*> getLocalDateTimeNamed("Installed From")
            <*> getContentNamed("AssetStatus")
            <*> getContentNamed("Loc.Ref.")

        
    def makeTextFacts(x: AibBaseRow): List[TextFact] = 
        use AssetLib/AibFacts/SetupDb/TextFact.{createNonEmpty};
        let o1 = createNonEmpty(x.reference, "Manufacturer", x.manufacturer);
        let o2 = createNonEmpty(x.reference, "Model", x.model);
        let o3 = createNonEmpty(x.reference, "Installed From", ToString.toString(x.installedFrom));
        let o4 = createNonEmpty(x.reference, "AssetStatus", x.assetStatus);
        let o5 = createNonEmpty(x.reference, "LocRef", x.locRef);
        List.filterMap(o -> o, o1 :: o2 :: o3 :: o4 :: o5 :: Nil)

}