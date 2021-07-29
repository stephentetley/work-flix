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


namespace AibRefCheck/Level2AibOverwriteUploads {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.RowEvaluator;
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/FileIO/S4/TransferFile/Datatypes.{ValuaFlocRow};
    
    /// pub rel InstReference(sainum: String)

    type alias SearchPath = 
        { glob: String
        , directory: System.FilePath
        }

    type alias Sources = 
        { worklist: XlsxSource
        , downloads: SearchPath
        , outpath: System.FilePath        
        }




    pub rel WorkItem(floc: String, pgSainum: String)

    type alias WorkItem1 = 
        { floc: String
        , pgSainum: String
        }

    type alias Counters = MutMap[String, (MutSet[Int32], MutSet[Int32])]

    def addCounter(mm: Counters, floc: String, counter: Int32): Unit & Impure = 
        match MutMap.get(floc, mm) {
            case None => MutMap.put!(floc, (MutSet.singleton(counter), MutSet.empty()), mm)
            case Some((s1, _)) => MutSet.add!(counter, s1)
        }

    /// TODO - if floc not found return None...
    def valcount(mm: Counters, floc: String): Option[Int32] & Impure = 
        match MutMap.get(floc, mm) {
            case None => None
            case Some((s1, s2)) => match MutSet.minimum(s1) { 
                case None => Some(first(s2))
                case Some(i) => {
                    MutSet.remove!(i, s1);
                    MutSet.add!(i, s2);
                    Some(i)
                }
            }
        }

    def first(s: MutSet[Int32]): Int32 & Impure = 
        firstHelper(s, 1)

    def firstHelper(s: MutSet[Int32], i: Int32): Int32 & Impure = 
        if (MutSet.memberOf(i, s))
            firstHelper(s, i+1)
        else {
            MutSet.add!(i, s);
            i
        }


    pub def genOverwrites(src: Sources): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let* mm         = AibRefCheck/Level2AibOverwriteUploads.readCounters(src.downloads);
        let* workitems  = AibRefCheck/Level2AibOverwriteUploads.readWorkItems(src.worklist);
        let rows        = List.filterMap(makeAnswer(mm), workitems);
        let* _          = AssetLib/FileIO/S4/TransferFile/Builtins.writeValuaFlocFile("tetleys", rows, src.outpath);
        Ok()

    /// TODO should be Option[ValuaFlocRow] for a filterMap
    def makeAnswer(mm: Counters, workitem: WorkItem1): Option[ValuaFlocRow] & Impure = 
        use Option.flatMap;
        let* counter = valcount(mm, workitem.floc);
        Some({ funcloc = workitem.floc
            , classType = "003"
            , charId = "AI2_AIB_REFERENCE"
            , charValue = workitem.pgSainum
            , code = Some(1)
            , valueDescription = workitem.pgSainum
            , instanceCounter = 0
            , intCounterValue = counter
            , valueFrom = ""
            , valueTo = ""
            })

        
    /// Loading...


    /// Read from IH06 export of sites
    pub def readWorkItems(src: XlsxSource): Result[List[WorkItem1], String] & Impure =
        SheetIO/Reader.readAllNamedRows(src, evalWorkItem())


    def evalWorkItem(): NamedRowEvaluator[WorkItem1] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> {floc = x1, pgSainum = x2})
            <&> getTrimmedContentNamed("Lv2")
            <*> getTrimmedContentNamed("ProcessGroupReference")
            
    /// TODO - read multiple files (return one Counters map)
    /// pub def readCounters(src: System.FilePath): Result[Counters, String] & Impure = 
    ///     use Result.{flatMap};
    ///     let* xs     = AssetLib/FileIO/S4/TransferFile/Builtins.readValuaFlocFile(src);
    ///     let mm      = MutMap.empty();
    ///     let _       = List.foreach(x1 -> addCounter(mm, x1.funcloc, x1.intCounterValue), xs);
    ///     Ok(mm)
            

    pub def readCounters(src: SearchPath): Result[Counters, String] & Impure = 
        use Result.{flatMap};
        let* files  = System/Directory.matches(src.glob, src.directory);
        let mm      = MutMap.empty();        
        let _       = Result.traverse(readCounters1(mm), files);
        Ok(mm)
    

    def readCounters1(mm: Counters, src: System.FilePath): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* xs     = AssetLib/FileIO/S4/TransferFile/Builtins.readValuaFlocFile(src);
        let _       = List.foreach(x1 -> addCounter(mm, x1.funcloc, x1.intCounterValue), xs);
        Ok()




    
    

}
