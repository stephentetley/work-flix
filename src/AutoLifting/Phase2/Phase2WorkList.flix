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

namespace AutoLifting/Phase2/Phase2WorkList {
    
    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;

    use AutoLifting/Datatypes.Phase2WorkItem1;
    use AutoLifting.ReportMonad;

    // Phase2WorkItem1
    /// Reference	Parent Reference	S4 Name	S4 Floc	Equi Category	Equi Object	Equi Class

    /// Must be a *.xlsx (OO-XML) file.
    pub def getWorkList(path: System.FilePath): ReportMonad[List[Phase2WorkItem1]] =
        use AutoLifting/ReportMonad.{liftActionResult};
        liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readWorkListRows(), path))
        

    def readWorkListRows() : SheetReader[List[Phase2WorkItem1]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetAt, maximalNamedRows}; 
        let* s1 = getSheetAt(0); 
        maximalNamedRows(s1, 0, 1, evalWorkListRow())

    def evalWorkListRow(): NamedRowEvaluator[Phase2WorkItem1] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getStringNamed, getStringNamedWithDefault};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7) -> 
                { pliReference          = x1
                , parentSaiReference    = x2
                , s4EquiName            = x3
                , s4Floc                = x4
                , s4Category            = x5
                , s4Object              = x6
                , s4Class               = x7
                })
            <&> getStringNamed("Reference")
            <*> getStringNamed("Parent Reference")
            <*> getStringNamed("S4 Name")
            <*> getStringNamed("S4 Floc")
            <*> getStringNamed("Equi Category")
            <*> getStringNamed("Equi Object")
            <*> getStringNamed("Equi Class")

}