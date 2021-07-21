/*
 * Copyright 2021 Stephen Tetley
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


namespace AssetScripts/NonOp/Relations {


    /// ACH flocs

    type alias AchFlocWorkItem = 
        { siteAibRef: String
        , instAibRef: String
        }



    type alias PlantEquipWorkItem = 
        { plinum: String                                /// Column: "AV"
        , commonName: String                            /// Column: "AM"
        , manufacturer: String                          /// Column: "AZ"
        , model: String                                 /// Column: "BA"
        , assetType: String                             /// Column: "BE"
        , installedFromDate: Option[Time.LocalDate]     /// Column: "AY"
        , processGroupName: String                      /// Column: "AA"
        , processName: String                           /// Column: "AH"
        , parentSainum: String                          /// Column: "AK"
        , installationSainum: String                    /// Column: "E"
        }




    pub rel InstallationMapping(instAibRef: String, s4SiteFloc: String)
    
    pub rel SiteEastNorth(siteFloc: String, easting: Int32, northing: Int32)



    pub rel GrandParentParentNames(equiId: String, procGroupName: String, procName: String)

    pub rel AssetTypeDescription(equiId: String, plantTypeDesc: String, plantEquiTypeDesc: String)
    
    pub rel EquipProperties(equiId: String, 
                            manufacturer: String, 
                            model: String, 
                            installedFromDate: Option[Time.LocalDate])

    pub rel PandITag(equiId: String, pandiTag: String)



    pub rel EquipmentMapping(plantAssetTypeDescription: String, 
                            plantEquipAssetTypeDescription: String, 
                            objectType: String, 
                            objectClass: String, 
                            category: String)


    /// temp
    pub rel PlantAssetType(code: String, desc: String)
}
