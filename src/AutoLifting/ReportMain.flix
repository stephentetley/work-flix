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

    use AutoLifting/Datatypes.{EquiWorkItem4, Phase2WorkItem3};
    use AutoLifting.ReportMonad;

    type alias ReportConfig = 
        { typeTablePath: System.FilePath
        , siteTablePath: System.FilePath
        , uxlTemplatePath: System.FilePath
        }

    type alias InputPaths = 
        { workListPath: System.FilePath
        , attribsPath: System.FilePath
        , memosPath: System.FilePath
        }

    pub def generateChildNewReport( reportConfig: ReportConfig
                                  , inputPaths: InputPaths
                                  , outPath: System.FilePath):  ReportMonad[Unit] = 
                                  
        use AutoLifting/ReportMonad.{return, flatMap, liftAction};
        let* _          = liftAction(_ -> Console.printLine("Running..."));
        let* xs1        = reportPhase1(reportConfig, inputPaths.workListPath);
        let* _          = reportPhase2(xs1, inputPaths, outPath);
        return()

    /// TODO use record for named args...
    def reportPhase1(reportConfig: ReportConfig,
                     workListPath: System.FilePath): ReportMonad[List[EquiWorkItem4]] = 
        use AutoLifting/ReportMonad.{return, flatMap};
        let* items      = AutoLifting/Phase1/Phase1WorkList.getWorkList(workListPath);
        let* xs1        = AutoLifting/Phase1/Naming.expandNames(items);
        let* parents    = AutoLifting/Phase1/ParentRef.loadSaiReferenceTable(workListPath);
        let* xs2        = AutoLifting/Phase1/ParentRef.updateParentReferences(parents, xs1);
        let* siteDb     = AutoLifting/Phase1/SiteMapping.loadSiteMapTable(reportConfig.siteTablePath);
        let* xs3        = AutoLifting/Phase1/SiteMapping.updateSiteCodes(siteDb, xs2);
        let* typeDb     = AutoLifting/Phase1/TypeMappingTable.readTypeMappingFile(reportConfig.typeTablePath);
        let* xs4        = AutoLifting/Phase1/TypeMapping.addTypeInfos(typeDb, xs3);
        return(xs4)

    
    def reportPhase2(xs: List[EquiWorkItem4],
                     inputPaths: InputPaths,
                     outPath: System.FilePath): ReportMonad[List[Phase2WorkItem3]] =
        use AutoLifting/ReportMonad.{return, flatMap, liftAction};     
        let* xs1        = AutoLifting/Phase2/Phase2WorkList.getWorkList(xs);
        let* memos      = AutoLifting/Phase2/LongText.loadMemoLookups(inputPaths.memosPath);
        let* xs2        = AutoLifting/Phase2/LongText.updateLongTexts(memos, xs1);
        let* attribs    = AutoLifting/Phase2/AddAttributes.loadAttributeLookups(inputPaths.attribsPath);
        let* xs3        = AutoLifting/Phase2/AddAttributes.updateAttributes(attribs, xs2);        
        let* xs4        = AutoLifting/Phase2/RenameValues.renameForS4(xs3);
        let* _          = AutoLifting/Phase2/Phase2Output.writePhase2Report(xs4, outPath);
        let* _          = liftAction(_ -> List.foreach(x -> Console.printLine(showPhase2WorkItem3(x)), xs4));
        return(xs4)

    pub def showPhase2WorkItem3(x: AutoLifting/Datatypes.Phase2WorkItem3): String = 
        let showOpt = o -> Option.getWithDefault(o, "_");
        "<${x.pliReference}, ${showOpt(x.longText)}, ${Time/LocalDate.toString(x.installedFrom)}, ${Int32.toString(x.easting)}, ${Int32.toString(x.northing)}>"



}