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

namespace AutoLifting/ReportMain {

    use AutoLifting.ReportMonad;

    /// TODO use record for named args...
    pub def reportPhase1( typeTablePath: System.FilePath
                        , siteTablePath: System.FilePath
                        , workListPath: System.FilePath
                        , outPath: System.FilePath): ReportMonad[Unit] = 
        use AutoLifting/ReportMonad.{return, flatMap, liftAction};
        let* _          = liftAction(_ -> Console.printLine("Running..."));
        let* items      = AutoLifting/Phase1/WorkList.getWorkList(workListPath);
        let* xs1        = AutoLifting/Phase1/Naming.expandNames(items);
        let* parents    = AutoLifting/Phase1/ParentRef.loadSaiReferenceTable(workListPath);
        let* xs2        = AutoLifting/Phase1/ParentRef.updateParentReferences(parents, xs1);
        let* siteDb     = AutoLifting/Phase1/SiteMapping.loadSiteMapTable(siteTablePath);
        let* xs3        = AutoLifting/Phase1/SiteMapping.updateSiteCodes(siteDb, xs2);
        let* typeDb     = AutoLifting/Phase1/MappingTable.readMappingFile(typeTablePath);
        let* xs4        = AutoLifting/Phase1/TypeMapping.addTypeInfos(typeDb, xs3);
        let* _          = AutoLifting/Phase1/OutputReport.writePhase1Report(xs4, outPath);
        let* _          = liftAction(_ -> List.foreach(x -> Console.printLine(showEquiWorkItem4(x)), xs4));
        return()

    pub def showEquiWorkItem4(x: AutoLifting/Datatypes.EquiWorkItem4): String = 
       "<${x.pliReference}, ${x.parentSaiReference}, ${x.s4EquiName}, ${x.s4Floc}, ${x.s4TyInfo.category}, ${x.s4TyInfo.s4Object}, ${x.s4TyInfo.s4Class}>"

    /// TODO use record for named args...
    pub def reportPhase2( workListPath: System.FilePath
                        , memosPath: System.FilePath
                        , attribsPath: System.FilePath
                        , _outPath: System.FilePath): ReportMonad[Unit] = 
        use AutoLifting/ReportMonad.{return, flatMap, liftAction};
        let* xs1      = AutoLifting/Phase2/WorkList.getWorkList(workListPath);
        let* _          = liftAction(_ -> Console.printLine("Work items: " + Int32.toString(List.length(xs1))));        
        let* memos      = AutoLifting/Phase2/LongText.loadMemoLookups(memosPath);
        let* xs2        = AutoLifting/Phase2/LongText.updateLongTexts(memos, xs1);
        let* attribs    = AutoLifting/Phase2/AddAttributes.loadAttributeLookups(attribsPath);
        let* xs3        = AutoLifting/Phase2/AddAttributes.updateAttributes(attribs, xs2);
        let* _          = liftAction(_ -> List.foreach(x -> Console.printLine(showPhase2WorkItem3(x)), xs3));
        return()

        pub def showPhase2WorkItem3(x: AutoLifting/Datatypes.Phase2WorkItem3): String = 
            let showOpt = o -> Option.getWithDefault(o, "_");
            "<${x.pliReference}, ${showOpt(x.s4LongText)}, ${Time/LocalDate.toString(x.installedFrom)}>"



}