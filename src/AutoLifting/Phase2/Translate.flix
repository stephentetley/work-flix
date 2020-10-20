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

namespace AutoLifting/Phase2/Translate {
    
    use AutoLifting/Datatypes.{Phase1FinalWorkItem, Phase2FinalWorkItem, AibAttributeRow};
    use AutoLifting.ReportMonad;


    pub def translate( memosMap: Map[String, String]
                     , attribsMap: Map[String, AibAttributeRow]
                     , x: Phase1FinalWorkItem): ReportMonad[Phase2FinalWorkItem] = 
        use AutoLifting/ReportMonad.{flatMap, return};
        let* longText   = AutoLifting/Phase2/LongText.getLongText(memosMap, x.pliReference);
        let* attrs      = AutoLifting/Phase2/AddAttributes.getAttributes(attribsMap, x.pliReference);
        return(
            { pliReference          = x.pliReference
            , parentSaiReference    = x.parentSaiReference
            , s4EquiName            = x.s4EquiName
            , s4Floc                = x.s4Floc
            , s4Category            = x.s4TyInfo.category
            , s4Object              = x.s4TyInfo.s4Object
            , s4Class               = x.s4TyInfo.s4Class
            , equiAttributes        = attrs.equiAttributes
            , longText              = longText
            , charAttributes        = attrs.charAttributes
            }
        )

}