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

namespace AutoLifting/Phase3/EmitUxl {

    use SheetIO.SheetWriter;
    use AssetLib/S4/FileIO/UxlFile/Datatypes.{ChangeRequestDetails, 
        EquipmentData, EqMultilingualText, EqClassification};
    
    use AssetLib/S4/Simple/Datatypes.{S4Equipment};
    use AssetLib/S4/Simple/EmitUxl.{outputS4Equipment};
    use AutoLifting/Common.ReportMonad;
    


    pub def writeputUxlFile( description: String
                           , xs: List[S4Equipment]
                           , templatePath: System.FilePath
                           , outPath: System.FilePath): ReportMonad[Unit] = 
        use AutoLifting/Common/ReportMonad.{liftActionResult};
        use SheetIO/SheetWriter.{runTemplateXssf};
        liftActionResult(_ -> runTemplateXssf(outputS4Equipment(description, xs), templatePath, outPath))


}