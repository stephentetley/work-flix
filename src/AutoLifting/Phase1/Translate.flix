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

namespace AutoLifting/Phase1/Translate {
    
    use AssetLib/Aib/FileIO/AideChangeSummary/Datatypes.{AibExportRow};
    
    use AutoLifting/Datatypes.{Phase1FinalWorkItem};
    use AutoLifting.ReportMonad;
    use AutoLifting/Phase1/TypeMapping.{Distinguished, Ordinary, TypeAnswer};

    pub def translate[s]( siteCodes: Map[String, String]
                        , parentIds: Map[String,String]
                        , typeDb: #{Distinguished, Ordinary, TypeAnswer | s}
                        , x: AibExportRow): ReportMonad[Phase1FinalWorkItem] = 
        use AutoLifting/ReportMonad.{flatMap, return, liftActionResult};
        let* aibNames       = AutoLifting/Phase1/Naming.getAibNames(x);
        let* s4SiteCode     = AutoLifting/Phase1/SiteMapping.getS4SiteCode(siteCodes, aibNames.siteName);
        let* saiParent      = AutoLifting/Phase1/ParentRef.getSaiParentReference(parentIds, x.newParentName);
        let* typeMap        = AutoLifting/Phase1/TypeMapping.getTypeInfo(typeDb, { s4SiteCode = s4SiteCode
                                                                                 , aibEquiName = aibNames.equiName
                                                                                 , aibEquiType = aibNames.equiType});
        let* s4EquiName     = liftActionResult(_ -> AutoLifting/Common.properCaseEquiName(aibNames.equiName));
        return(
            { aibEquiName           = aibNames.equiName
            , aibEquiType           = aibNames.equiType
            , pliReference          = x.reference
            , s4EquiName            = s4EquiName
            , s4SiteCode            = s4SiteCode
            , parentSaiReference    = saiParent
            , s4TyInfo              = typeMap.s4TyInfo
            , s4Floc                = typeMap.s4Floc
            })


}