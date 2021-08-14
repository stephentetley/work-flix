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


namespace AibRefCheck/Level1/Loader {

    use SheetIO.NamedRowEvaluator;   
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/FileIO/S4/TransferFile.DownloadRowEvaluator;

    use AibRefCheck/Level1/Relations.{SiteMapping, InstMapping, SiteExists, IH06Match, ValCount, ValCounts};


    /// Loading...

    /// Read from Level1_Floc_Mapping file
    pub def readSiteMapping(src: XlsxSource): Result[#{SiteMapping | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalSiteMapping())


    def evalSiteMapping(): NamedRowEvaluator[#{SiteMapping | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> Relation.whenNot(String.isEmpty(x1) or String.isEmpty(x2)), #{ SiteMapping(x1, x2). }))
            <&> getTrimmedContentNamed("S/4 Hana Floc Lvl1_Code")
            <*> getTrimmedContentNamed("SITE_REF")
            
    /// Read from Level1_Floc_Mapping file
    pub def readInstMapping(src: XlsxSource): Result[#{InstMapping | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalInstMapping())


    def evalInstMapping(): NamedRowEvaluator[#{InstMapping | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> Relation.whenNot(String.isEmpty(x1) or String.isEmpty(x2), #{ InstMapping(x1, x2). }))
            <&> getTrimmedContentNamed("S/4 Hana Floc Lvl1_Code")
            <*> getTrimmedContentNamed("AI2_InstallationReference")

    /// Read from IH06 export of sites
    pub def readIH06Match(src: XlsxSource): Result[#{IH06Match | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalIH06Match())


    def evalIH06Match(): NamedRowEvaluator[#{IH06Match | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> Relation.whenNot(String.isEmpty(x1) or String.isEmpty(x2), #{ IH06Match(x1, x2). }))
            <&> getTrimmedContentNamed("Functional Loc.")
            <*> getTrimmedContentNamed("AI2 AIB Reference")
    
    /// Read from IH06 export of sites
    pub def readSiteExists(src: XlsxSource): Result[#{SiteExists | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalSiteExists())


    def evalSiteExists(): NamedRowEvaluator[#{SiteExists | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        (x1 -> Relation.whenNot(String.isEmpty(x1), #{ SiteExists(x1). }))
            <&> getTrimmedContentNamed("Functional Loc.")


    pub def readValCountFiles(srcdir: System.FilePath): Result[ValCounts, String] & Impure = 
        use Result.{flatMap};
        let mm = MutMap.empty();
        let fn = path -> {
            // `mm` in scope
            let* xs = readValCountFile(path);
            let _   = List.foreach(vc -> MutMap.putWith!((v1, v2) -> Int32.max(v1, v2), vc.level1Code, vc.valcount, mm), xs);
            Ok()
        };
        let* files  = System/Directory.matches("level1_*.txt", srcdir);
        let* _      = Result.traverse(fn, files);
        Ok(mm)
        

    pub def readValCountFile(src: System.FilePath): Result[List[ValCount], String] & Impure = 
        let fn = row -> {level1Code = row.funcloc, valcount = row.intCounterValue};
        AssetLib/FileIO/S4/TransferFile/Builtins.readValuaFlocFile(src)
            |> Result.map(List.map(fn))

}
