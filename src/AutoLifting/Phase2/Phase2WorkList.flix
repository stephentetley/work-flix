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
    
    use AutoLifting/Datatypes.{Phase1FinalWorkItem, Phase2WorkItem1};
    use AutoLifting.ReportMonad;

    // Phase2WorkItem1
    /// Reference	Parent Reference	S4 Name	S4 Floc	Equi Category	Equi Object	Equi Class

    /// Must be a *.xlsx (OO-XML) file.
    pub def getWorkList(xs: List[Phase1FinalWorkItem]): ReportMonad[List[Phase2WorkItem1]] =
        use AutoLifting/ReportMonad.{mapM};
        mapM(translate, xs)
        

    def translate(x: Phase1FinalWorkItem): ReportMonad[Phase2WorkItem1] = 
        use AutoLifting/ReportMonad.{return};
        return({ pliReference           = x.pliReference
                , parentSaiReference    = x.parentSaiReference
                , s4EquiName            = x.s4EquiName
                , s4Floc                = x.s4Floc
                , s4Category            = x.s4TyInfo.category
                , s4Object              = x.s4TyInfo.s4Object
                , s4Class               = x.s4TyInfo.s4Class
                })

}