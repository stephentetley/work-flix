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

    use AutoLifting/Datatypes.{Phase1FinalWorkItem, Phase2FinalWorkItem};
    use AutoLifting.ReportMonad;

    type alias ReportConfig = 
        { typeTablePath: System.FilePath
        , liftingTablePath: System.FilePath
        , siteTablePath: System.FilePath
        , uxlTemplatePath: System.FilePath
        }

    type alias ReportProperties = 
        { workListPath: System.FilePath
        , attribsPath: System.FilePath
        , memosPath: System.FilePath
        , reportDescription: String
        , phase2OutPath: System.FilePath
        , uxlOutPath: System.FilePath
        }

    pub def generateChildNewReport( reportConfig: ReportConfig
                                  , reportProps: ReportProperties ):  ReportMonad[Unit] = 
                                  
        use AutoLifting/ReportMonad.{return, flatMap, liftAction};
        let* _          = liftAction(_ -> Console.printLine("Running..."));
        let* xs1        = reportPhase1(reportConfig, reportProps.workListPath);
        let* xs2        = reportPhase2(reportProps, xs1);
        let* _          = reportEmitUxlFile(reportConfig, reportProps, xs2);
        return()

    
    def reportPhase1(reportConfig: ReportConfig,
                     workListPath: System.FilePath): ReportMonad[List[Phase1FinalWorkItem]] = 
        use AutoLifting/ReportMonad.{return, flatMap, mapM};
        use AutoLifting/Phase1/Translate.{translate};
        let* items      = AutoLifting/Phase1/Phase1WorkList.getWorkList(workListPath);
        let* siteCodes  = AutoLifting/Phase1/SiteMapping.loadSiteMapTable(reportConfig.siteTablePath);
        let* parentIds  = AutoLifting/Phase1/ParentRef.loadSaiReferenceTable(workListPath);
        let* typeDb     = AutoLifting/Phase1/TypeMapping.readTypeMappingFile(reportConfig.typeTablePath);
        mapM(translate(siteCodes, parentIds, typeDb), items)
        

    
    def reportPhase2(reportProps: ReportProperties, xs: List[Phase1FinalWorkItem]): ReportMonad[List[Phase2FinalWorkItem]] =
        use AutoLifting/ReportMonad.{flatMap, return, liftAction, mapM};   
        use AutoLifting/Phase2/Translate.{translate};  
        let* memos      = AutoLifting/Phase2/LongText.loadMemoLookups(reportProps.memosPath);
        let* attribs    = AutoLifting/Phase2/AddAttributes.loadAttributeLookups(reportProps.attribsPath);
        let* xs1        = mapM(translate(memos, attribs), xs);
        let* xs2        = AutoLifting/Phase2/RenameValues.renameForS4(xs1);
        let* _          = AutoLifting/Phase2/Phase2Output.writePhase2Report(xs2, reportProps.phase2OutPath);
        let* _          = liftAction(_ -> List.foreach(x -> Console.printLine(showPhase2FinalWorkItem(x)), xs2));
        return(xs2)

    def showPhase2FinalWorkItem(x: AutoLifting/Datatypes.Phase2FinalWorkItem): String = 
        let showOpt = o -> Option.getWithDefault(o, "_");
        "<${x.pliReference}, ${showOpt(x.longText)}, ${Time/LocalDate.toString(x.equiAttributes.installedFrom)}>"

    def reportEmitUxlFile(reportConfig: ReportConfig,
                          reportProps: ReportProperties, 
                          xs: List[Phase2FinalWorkItem]): ReportMonad[Unit] =
        use AutoLifting/ReportMonad.{flatMap, return, mapM}; 
        use AutoLifting/Phase3/EmitUxl.{writeputUxlFile};
        let* liftings   = AutoLifting/Phase3/LiftingClassifications.loadLiftingMapping(reportConfig.liftingTablePath);
        let* xs1        = mapM(AutoLifting/Phase3/Translate.translate(liftings), xs);
        let* _          = writeputUxlFile(reportProps.reportDescription,
                                          xs1, 
                                          reportConfig.uxlTemplatePath,
                                          reportProps.uxlOutPath);
        return()


}