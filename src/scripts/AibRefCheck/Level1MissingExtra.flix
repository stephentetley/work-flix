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


namespace AibRefCheck/Level1MissingExtra {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.RowEvaluator;
    use SheetIO.RowSetter;
    use SheetIO/Reader.{XlsxSource};
    
    pub rel S4MaptoAib(level1Code: String, sainum: String)

    pub rel IH06SiteWithSai(level1Code: String, sainum: String)

    pub rel MissingSainum(level1Code: String, sainum: String)

    pub rel InvalidSainum(level1Code: String, sainum: String)


    type alias Source = 
        { siteMapping: XlsxSource
        , ih06Export: XlsxSource
        }

    pub def readSource(src: Source): Result[#{S4MaptoAib, IH06SiteWithSai | r}, String] & Impure =
        use Result.{flatMap};
        let* smap       = readMaptoS4(src.siteMapping);
        let* ih06       = readIH06SiteWithSai(src.ih06Export);
        Ok(smap <+> ih06)




    pub def genAnswers(db: #{S4MaptoAib, IH06SiteWithSai, 
                            MissingSainum, InvalidSainum |r}): #{MissingSainum, InvalidSainum | r1} =                             
        let rules = #{

            MissingSainum(level1, sainum) :- 
                S4MaptoAib(level1, sainum),
                not IH06SiteWithSai(level1, sainum).
            
            InvalidSainum(level1, sainum) :- 
                IH06SiteWithSai(level1, sainum),
                not S4MaptoAib(level1, sainum).

        };    
    solve (db <+> rules) project MissingSainum, InvalidSainum

    pub def exportAnswers(solns: #{MissingSainum, InvalidSainum | r}, outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let headers1    = ["Level1_code", "Sainum"];
        let writer1     = {sheetName = "Missing", headers = Some(headers1), setter = setStringX2!, 
                            rows = query solns select (x,y) from MissingSainum(x,y) |> Array.toList};
        let* _          = SheetIO/Writer.writeWorkSheet(writer1, outpath);
        let headers2    = ["Level1_code", "Sainum"];
        let writer2     = {sheetName = "Extra_invalid", headers = Some(headers2), setter = setStringX2!, 
                            rows = query solns select (x,y) from InvalidSainum(x,y) |> Array.toList};
        let* _          = SheetIO/Writer.addWorkSheet(writer2, outpath);
        Ok()
        


    /// Loader...



    
    
    /// Read from site mapping v17 of sites
    pub def readMaptoS4(src: XlsxSource): Result[#{S4MaptoAib | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalS4MaptoAib())


    def evalS4MaptoAib(): NamedRowEvaluator[#{S4MaptoAib | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) -> { 
                let r1 = RelLib/Relation.when(not String.isEmpty(x1) and not String.isEmpty(x2), #{ S4MaptoAib(x1, x2). });
                let r2 = RelLib/Relation.when(not String.isEmpty(x1) and not String.isEmpty(x3), #{ S4MaptoAib(x1, x3). });
                r1 <+> r2})
            <&> getTrimmedContentNamed("S/4 Hana Floc Lvl1_Code")
            <*> getTrimmedContentNamed("AI2_InstallationReference")
            <*> getTrimmedContentNamed("SITE_REF")


    /// Read from ih06 export
    pub def readIH06SiteWithSai(src: XlsxSource): Result[#{IH06SiteWithSai | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalIH06SiteWithSai())


    def evalIH06SiteWithSai(): NamedRowEvaluator[#{IH06SiteWithSai | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> #{ IH06SiteWithSai(x1, x2). })
            <&> getTrimmedContentNamed("Functional Loc.")
            <*> getTrimmedContentNamed("AI2 AIB Reference")



    /// SheetWriter
 

    def setStringX2!(x: (String, String)): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        let (x1, x2) = x;
        let* _      = putStringAt!(0, x1);
        let* _      = putStringAt!(1, x2);
        return() 

}
