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

    use AutoLifting/Datatypes.{EquiWorkItem2};

    pub def reportPhase1( typeTablePath: System.FilePath
                        , workListPath: System.FilePath): ReportMonad[Unit] = 
        use AutoLifting/ReportMonad.{return, flatMap, liftAction, mapM};
        let* _          = liftAction(_ -> Console.printLine("Running..."));
        let* _db         = AutoLifting/MappingTable.readMappingFile(typeTablePath);
        let* xs1        = AutoLifting/Phase1WorkList.getWorkList(workListPath);
        let* xs2        = AutoLifting/Phase1Naming.expandNames(xs1);
        let* parents    = AutoLifting/Phase1ParentRef.loadSaiReferenceTable(workListPath);
        let* xs3        = AutoLifting/Phase1ParentRef.updateParentReferences(parents, xs2);
        let* _          = liftAction(_ -> List.foreach(x -> Console.printLine(showEquiWorkItem2(x)), xs3));
        return()

    pub def showEquiWorkItem2(x: EquiWorkItem2): String = 
       "<${x.aibEquiName}, ${x.aibEquiType}, ${x.s4EquiName}, _, _>"



}