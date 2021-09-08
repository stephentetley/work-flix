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



namespace CsoMigration/Loader {

    use SheetIO.NamedRowEvaluator;

    use CsoMigration/Relations.{AibCso, FlocMapping, Level1, Level2, Level3, Level4, Level5};

    type alias SourceFiles = 
        { aibCsoExport: System.FilePath         /// Always "Sheet1"
        , flocMapping: System.FilePath          /// 
        , s4Level1: System.FilePath
        , s4Level2: System.FilePath
        , s4Level3: System.FilePath
        , s4Level4: System.FilePath
        , s4Level5: System.FilePath
        }

    pub def loadAll(srcs: SourceFiles): Result[#{AibCso, FlocMapping, Level1, 
                                                    Level2, Level3, Level4, Level5 | r}, String] & Impure = 
        use Result.{flatMap};
        let* x1 = loadAibCso(srcs);
        let* x2 = loadFlocMapping(srcs);
        let* x3 = loadLevel1(srcs);
        let* x4 = loadLevel2(srcs);
        let* x5 = loadLevel3(srcs);
        let* x6 = loadLevel4(srcs);
        let* x7 = loadLevel5(srcs);
        let _   = Console.printLine("Loaded. ${Time/LocalTime.now()}");
        Ok(x1 <+> x2 <+> x3 <+> x4 <+> x5 <+> x6 <+> x7)

    pub def loadAibCso(srcs: SourceFiles): Result[#{AibCso | r}, String] & Impure = 
        SheetIO/Reader.allNamedRelations({path = srcs.aibCsoExport, sheet = "Sheet1"}, evalAibCsoRow())

    def evalAibCsoRow(): NamedRowEvaluator[#{AibCso | r}] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) -> #{ AibCso(x1, x2, x3). })
            <&> getTrimmedContentNamed("Common Name")
            <*> getTrimmedContentNamed("Reference")
            <*> getTrimmedContentNamed("AssetStatus")

    pub def loadFlocMapping(srcs: SourceFiles): Result[#{FlocMapping | r}, String] & Impure = 
        SheetIO/Reader.someNamedRelations({path = srcs.flocMapping, sheet = "inst to SAP migration"}, evalFlocMappingRow())

    def evalFlocMappingRow(): NamedRowEvaluator[#{FlocMapping | r}] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4) -> #{ FlocMapping(x1, x2, x3, x4). })
            <&> getTrimmedContentNamed("AI2_InstallationCommonName")
            <*> getTrimmedContentNamed("AI2_InstallationReference")
            <*> getTrimmedContentNamed("S/4 Hana Floc Lvl1_Code")
            <*> getTrimmedContentNamed("S/4 Hana Floc Description")


    pub def loadLevel1(srcs: SourceFiles): Result[#{Level1 | r}, String] & Impure = 
        let cons = (x1, x2) -> #{ Level1(x1, x2). };
        SheetIO/Reader.someNamedRelations({path = srcs.s4Level1, sheet = "Sheet1"}, evalLevelRow(cons))

    pub def loadLevel2(srcs: SourceFiles): Result[#{Level2 | r}, String] & Impure = 
        let cons = (x1, x2) -> #{ Level2(getSite(x1), x1, x2). };
        SheetIO/Reader.someNamedRelations({path = srcs.s4Level2, sheet = "Sheet1"}, evalLevelRow(cons))
        
    pub def loadLevel3(srcs: SourceFiles): Result[#{Level3 | r}, String] & Impure = 
        let cons = (x1, x2) -> #{ Level3(getSite(x1), x1, x2). };
        SheetIO/Reader.someNamedRelations({path = srcs.s4Level3, sheet = "Sheet1"}, evalLevelRow(cons))
        
    pub def loadLevel4(srcs: SourceFiles): Result[#{Level4 | r}, String] & Impure = 
        let cons = (x1, x2) -> #{ Level4(getSite(x1), x1, x2). };
        SheetIO/Reader.someNamedRelations({path = srcs.s4Level4, sheet = "Sheet1"}, evalLevelRow(cons))

    pub def loadLevel5(srcs: SourceFiles): Result[#{Level5 | r}, String] & Impure = 
        let cons = (x1, x2) -> #{ Level5(getSite(x1), x1, x2). };
        SheetIO/Reader.someNamedRelations({path = srcs.s4Level5, sheet = "Sheet1"}, evalLevelRow(cons))

    def getSite(x: String): String = String.take(5, x)

    def evalLevelRow(cons: (String, String) -> r1): NamedRowEvaluator[r1] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        /// ((x1, x2) -> cons(x1, x2))
        cons
            <&> getTrimmedContentNamed("Functional Loc.")
            <*> getTrimmedContentNamed("Description")


}
