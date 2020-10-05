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

namespace AutoLifting/Phase2/AddAttributes {
    
 
    use AutoLifting/Datatypes.{Phase2WorkItem2, AibAttributeRow, Phase2WorkItem3};
    use AutoLifting.ReportMonad;

    pub def loadAttributeLookups(path: System.FilePath): ReportMonad[Map[String, AibAttributeRow]] =
        use AutoLifting/ReportMonad.{map}; 
        map(buildAttributeLookups, 
            AutoLifting/Phase2/AibAttributeReader.getAibAttributeRows(path)
        )
        

    pub def updateAttributes(m: Map[String, AibAttributeRow], xs: List[Phase2WorkItem2]): ReportMonad[List[Phase2WorkItem3]] = 
        AutoLifting/ReportMonad.mapM(updateAttributes1(m), xs)

    pub def updateAttributes1(m: Map[String, AibAttributeRow], x: Phase2WorkItem2): ReportMonad[Phase2WorkItem3] = 
        use AutoLifting/ReportMonad.{flatMap, return, throwError};
        match Map.get(x.pliReference, m) {
            case None => throwError("updateLongText - No attributes for ${x.pliReference}")
            case Some(attrs) => { 
                // let v1 = attrs.installedFrom;
                let x1 = { +installedFrom = attrs.installedFrom | x }; 
                return(x1)
            }
        }
        

    def buildAttributeLookups(xs: List[AibAttributeRow]): Map[String, AibAttributeRow] = 
        List.foldLeft((ac, x) ->  Map.insert(x.pliReference, x, ac), Map.empty(), xs)


}