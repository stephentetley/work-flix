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

namespace AutoLifting/Phase3/Translate {
    
    use AutoLifting/Common/Datatypes.{Phase2FinalWorkItem, Phase3FinalWorkItem, 
        EquiMultilingualText, EquiData};
    use AutoLifting/Common.ReportMonad;


    pub def translate(liftingData: Map[String, (String, String)], x: Phase2FinalWorkItem): ReportMonad[Phase3FinalWorkItem] = 
        use AutoLifting/Common/ReportMonad.{flatMap, return, genEquiId};
        use AutoLifting/Phase3/LiftingClassifications.{getFixedClassifications, getWorkLoadClassifications};
        let* equiId1    = genEquiId();
        let* equiData   = getEquiData(x);
        let* mltext     = getMultilingualText(x);
        let* cs1        = getFixedClassifications(x);
        let* cs2        = getWorkLoadClassifications(liftingData, x);
        return(
            { s4EquiId          = equiId1
            , s4EquiName        = x.s4EquiName
            , s4Class           = x.s4Class
            , equiData          = equiData
            , multilingualText  = mltext
            , classifications   = cs1 ::: cs2
            }
        )

    def getEquiData(x: Phase2FinalWorkItem): ReportMonad[EquiData] = 
        use AutoLifting/Common/ReportMonad.{return};
        return(
            { category              = x.s4Category
            , description           = x.s4EquiName
            , objectType            = x.s4Object
            , startupDate           = x.equiAttributes.installedFrom
            , manufacturer          = x.equiAttributes.manufacturer
            , model                 = x.equiAttributes.model
            , partNumber            = x.equiAttributes.partNumber
            , serialNumber          = x.equiAttributes.serialNumber
            , functionalLocation    = x.s4Floc
            })

    pub def getMultilingualText[r](x: { s4EquiName: String
                                      , longText: Option[String] | r}): ReportMonad[Option[EquiMultilingualText]] = 
        use AutoLifting/Common/ReportMonad.{return};
        match x.longText {
            case Some(s) if (String.length(s) >= 30) => return(Some({description = x.s4EquiName, longText = s}))
            case _ => return(None)
        }

}