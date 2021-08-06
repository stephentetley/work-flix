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


namespace AibRefCheck/Level5Cso {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.RowEvaluator;
    use SheetIO.RowSetter;
    use SheetIO/Reader.{XlsxSource};
    
    pub rel AibInstallation(instName: String, instType: String)

    pub rel MaptoS4(aibInstName: String, level1Code: String)

    pub rel WtnSofFls(level1Code: String, level5Code: String, description: String)

    pub rel CsoWithFLS(instName: String, level5Code: String, description: String)

    pub rel CsoWithoutFLS(instName: String, level1Code: String)

    pub rel HasMaptoS4(aibInstName: String)

    pub rel HasWtnSofFls(level1Code: String)

    type alias Source = 
        { siteMapping: XlsxSource
        , ih06Export: XlsxSource
        }

    pub def readSource(src: Source): Result[#{AibInstallation, MaptoS4, WtnSofFls | r}, String] & Impure =
        use Result.{flatMap};
        let* insts      = readAibInstallation(src.siteMapping);
        let* mapping    = readMaptoS4(src.siteMapping);
        let* csos       = readWtnSofFls(src.ih06Export);
        Ok(insts <+> mapping <+> csos)




    pub def genAnswers(db: #{AibInstallation, MaptoS4, WtnSofFls, 
                            HasMaptoS4, HasWtnSofFls, 
                            CsoWithFLS, CsoWithoutFLS |r}): #{CsoWithFLS, CsoWithoutFLS | r1} =                             
        let rules = #{

            HasMaptoS4(aibInstName) :- MaptoS4(aibInstName, _).
            HasWtnSofFls(leve1Code) :- WtnSofFls(leve1Code, _, _).

            CsoWithFLS(instName, level5Code, description) :- 
                AibInstallation(instName, "CSO"),
                MaptoS4(instName, level1Code),
                WtnSofFls(level1Code, level5Code, description).

            CsoWithoutFLS(instName, "No Level1 Mapping") :- 
                AibInstallation(instName, "CSO"),
                not HasMaptoS4(instName).

            CsoWithoutFLS(instName, level1Code) :- 
                AibInstallation(instName, "CSO"),
                MaptoS4(instName, level1Code), 
                not HasWtnSofFls(level1Code).

        };    
    solve (db <+> rules) project CsoWithFLS, CsoWithoutFLS

    pub def exportAnswers(solns: #{CsoWithFLS, CsoWithoutFLS | r}, outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let headers1    = ["Installation_name", "Level5_code", "Description"];
        let writer1     = {sheetName = "CSO_with_FLS", headers = Some(headers1), setter = setCsoWithFLS!, 
                            rows = query solns select (x,y,z) from CsoWithFLS(x,y,z) |> Array.toList};
        let* _          = SheetIO/Writer.writeWorkSheet(writer1, outpath);
        let headers2    = ["Installation_name", "Level1_code"];
        let writer2     = {sheetName = "CSO_without_FLS", headers = Some(headers2), setter = setCsoWithoutFLS!, 
                            rows = query solns select (x,y) from CsoWithoutFLS(x,y) |> Array.toList};
        let* _          = SheetIO/Writer.addWorkSheet(writer2, outpath);
        Ok()
        


    /// Loader...


    /// Read from site mapping v17 of sites
    pub def readAibInstallation(src: XlsxSource): Result[#{AibInstallation | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalAibInstallation())


    def evalAibInstallation(): NamedRowEvaluator[#{AibInstallation | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> #{ AibInstallation(x1, x2). })
            <&> getTrimmedContentNamed("AI2_InstallationCommonName")
            <*> getTrimmedContentNamed("AI2_InstallationAssetType")

    
    
    /// Read from site mapping v17 of sites
    pub def readMaptoS4(src: XlsxSource): Result[#{MaptoS4 | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalMaptoS4())


    def evalMaptoS4(): NamedRowEvaluator[#{MaptoS4 | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> if (not String.isEmpty(x2)) #{ MaptoS4(x1, x2). } else #{})
            <&> getTrimmedContentNamed("AI2_InstallationCommonName")
            <*> getTrimmedContentNamed("S/4 Hana Floc Lvl1_Code")

    /// Read from ih06 export
    pub def readWtnSofFls(src: XlsxSource): Result[#{WtnSofFls | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalWtnSofFls())


    def evalWtnSofFls(): NamedRowEvaluator[#{WtnSofFls | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> #{ WtnSofFls(getL1(x1), x1, x2). })
            <&> getTrimmedContentNamed("Functional Loc.")
            <*> getTrimmedContentNamed("Description")


    def getL1(floc: String): String = 
        String.breakOnLeft("-", floc) |> fst


    /// SheetWriter

    def setCsoWithFLS!(x: (String, String, String)): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putInt32At!};
        let (x1, x2, x3) = x;
        let* _      = putStringAt!(0, x1);
        let* _      = putStringAt!(1, x2);
        let* _      = putStringAt!(2, x3);
        return() 

    def setCsoWithoutFLS!(x: (String, String)): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putInt32At!};
        let (x1, x2) = x;
        let* _      = putStringAt!(0, x1);
        let* _      = putStringAt!(1, x2);
        return() 

}
