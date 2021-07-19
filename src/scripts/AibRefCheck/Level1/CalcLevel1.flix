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


namespace AibRefCheck/Level1/CalcLevel1 {

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.{ValuaFlocRow};

    use AibRefCheck/Level1/Relations.{SiteMapping, InstMapping, SiteExists, IH06Match, ValCounts};

    type alias CalcSources = 
        { level1SiteMapping: XlsxSource
        , ih06SiteExport: XlsxSource
        , valuaFlocDownloads: System.FilePath
        }

    pub def readSource(src: CalcSources): Result[#{SiteMapping, InstMapping, SiteExists, IH06Match |r}, String] & Impure =
        use Result.{flatMap};
        let* sitem      = AibRefCheck/Level1/Loader.readSiteMapping(src.level1SiteMapping);
        let* instm      = AibRefCheck/Level1/Loader.readInstMapping(src.level1SiteMapping);
        let* existing   = AibRefCheck/Level1/Loader.readSiteExists(src.ih06SiteExport);
        let* matches    = AibRefCheck/Level1/Loader.readIH06Match(src.ih06SiteExport);
        Ok(sitem <+> instm <+> existing <+> matches)


    pub rel MissingRef(level1Code: String, sainum: String, siteOrInst: String)
    pub rel HasSiteMatch(level1Code: String, sainum: String)
    pub rel HasInstMatch(level1Code: String, sainum: String)



    pub def getMissingRefs(db: #{SiteMapping, InstMapping, SiteExists, IH06Match,
                        MissingRef, HasSiteMatch, HasInstMatch |r}): #{MissingRef | r1} = 
        let rules = #{

            HasSiteMatch(level1Code, sainum) :- 
                SiteMapping(level1Code, sainum), 
                IH06Match(level1Code, sainum).

            HasInstMatch(level1Code, sainum) :- 
                InstMapping(level1Code, sainum), 
                IH06Match(level1Code, sainum).

            MissingRef(level1Code, sainum, "SITE") :- 
                SiteExists(level1Code),
                SiteMapping(level1Code, sainum),
                not HasSiteMatch(level1Code, sainum).
        
            MissingRef(level1Code, sainum, "INST") :- 
                SiteExists(level1Code),
                InstMapping(level1Code, sainum),
                not HasInstMatch(level1Code, sainum).

        };    
        solve (db <+> rules) project MissingRef    
    

    pub def makeMissingValuaFlocs(mm: ValCounts, xs: List[(String, String, String)]): List[List[ValuaFlocRow]] & Impure = 
        xs  
            |> List.map(makeMissingValuaFloc(mm))
            |> List.sortWith((x, y) -> Order.compare(x.funcloc, y.funcloc))
            |> AibRefCheck/Level1/Utils.sublists(500)


    def makeMissingValuaFloc(mm: ValCounts, xyz: (String, String, String)): ValuaFlocRow & Impure = 
        let (level1Code, sainum, _) = xyz;
        let vc = nextValCount(mm, level1Code);
        { funcloc           = level1Code
        , classType         = "003"
        , charId            = "AI2_AIB_REFERENCE" 
        , charValue         = sainum
        , code              = Some(1)
        , valueDescription  = sainum
        , instanceCounter   = 0
        , intCounterValue   = vc
        , valueFrom         = ""
        , valueTo           = ""
        }



    pub def nextValCount(mm: ValCounts, level1Code: String): Int32 & Impure = 
        match MutMap.get(level1Code, mm) {
            case Some(i) => {MutMap.put!(level1Code, i + 1, mm); i + 1}
            case None => {MutMap.put!(level1Code, 1, mm); 1}
        }


    pub def writeValuaFlocFiles(outdir: System.FilePath, xss: List[List[ValuaFlocRow]]): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let fn = (ac, xs1) -> match ac {
            case Err(msg) => Err(msg)
            case Ok(i) => {
                let* _  = writeValuaFlocFile1(outdir, i, xs1);
                Ok(i+1)
            }
        };
        let* _ = List.foldLeft(fn, Ok(1), xss);
        Ok()

    def writeValuaFlocFile1(outdir: System.FilePath, batch: Int32, xs: List[ValuaFlocRow]): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use System/FilePath.{<<>>};
        let num         = String.padLeft(3, '0', "${batch}");
        let outpath     = outdir <<>> "Valuafloc_level1_${num}.txt";
        let _           = Console.printLine("Writing: ${outpath}");
        AssetLib/FileIO/S4/TransferFile/Builtins.writeValuaFlocFile("tetleys", xs, outpath)

}
