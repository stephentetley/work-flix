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


    /// PlantEquip (aka Super equipment)
    /// This covers both PlantEquip and PlatItems with no parent (typically lifting equipment)

    type alias SuperEquiWorkItem = 
        { plinum: String                                /// Column: "AV"/"CM"
        , commonName: String                            /// Column: "AM"/"CD"
        , manufacturer: String                          /// Column: "AZ"/"CQ"
        , model: String                                 /// Column: "BA"/"CR"
        , plantAssetType: String                        /// Column: "AS"/"CJ" (e.g. "TANK", "SCREEN")
        , plantEquipAssetType: String                   /// Column: "BE"/"CV" (e.g. "EQUIPMENT: STORM SEDIMENTATION TANK")
        , installedFromDate: Option[Time.LocalDate]     /// Column: "AY"/"CP"
        , processGroupName: String                      /// Column: "AA"/"AA" (e.g. "SECONDARY TREATMENT")
        , processName: String                           /// Column: "AH"/"AH" (e.g. "WASHWATER PUMPING", "LIFTING EQUIPMENT")
        , parentSainum: String                          /// Column: "AK"/"CB" [needed for AI2_AIB_REFERENCE]
        , installationSainum: String                    /// Column: "E"
        , subinstallationSainum: String                 /// Column: "M"  (might be "NULL")
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
