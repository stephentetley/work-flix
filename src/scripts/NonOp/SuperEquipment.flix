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


namespace AssetScripts/NonOp/SuperEquipment {

    use AssetLib/GenS4/S4LiteRelations.{Equipment, EquiLongText, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Date, S4Int, S4Float};
    use AssetScripts/NonOp/Relations.{SuperEquipWorkItem, GrandParentParentNames,
        AssetTypeDescription, EquipmentMapping, EquipProperties, SiteFloc, PandITag};


    
    pub def genEqui(today: Time.LocalDate, 
                    db: #{SuperEquipWorkItem, GrandParentParentNames,
                            AssetTypeDescription, EquipmentMapping, EquipProperties, SiteFloc, PandITag,
                            Equipment, EquiLongText, EquiCharacteristic | r}): #{Equipment, EquiLongText, EquiCharacteristic | r} = 
        use AssetScripts/NonOp/Utils.{getShortName};
        let noneI32: Option[Int32] = None;
        let rules = #{
        
            Equipment(equiId, 
                        category,
                        getShortName(procGroupName, procName, commonName),
                        today,
                        objectType,
                        weightKg,
                        installedFromDate,
                        manufacturer,
                        model,
                        partNumber,
                        serialNumber,
                        "${sitefloc}-ACH-ACH-ACH-NON01",        /// functionalLocation
                        "",                                     /// superOrdinateEqui
                        noneI32,                                /// position
                        techIdentNo,
                        "NOP") :- 
                SuperEquipWorkItem(equiId, commonName, aibSiteRef),
                AssetTypeDescription(equiId, plantTypeDesc, plantEquiTypeDesc),                
                GrandParentParentNames(equiId, procGroupName, procName),
                EquipmentMapping(plantTypeDesc, plantEquiTypeDesc, objectType, _, category), 
                EquipProperties(equiId, manufacturer, model, partNumber, serialNumber, installedFromDate, weightKg),
                SiteFloc(aibSiteRef, sitefloc), 
                PandITag(equiId, techIdentNo).

            /// Multilingual text

            EquiLongText(equiId, getShortName(procGroupName, procName, commonName), commonName) :- 
                SuperEquipWorkItem(equiId, commonName, _),
                GrandParentParentNames(equiId, procGroupName, procName).

            /// Characteristics

            EquiCharacteristic(equiId, oclass, "UNICLASS_CODE", 1, S4String("")) :-
                SuperEquipWorkItem(equiId, _, _),
                AssetTypeDescription(equiId, plantTypeDesc, plantEquiTypeDesc),
                EquipmentMapping(plantTypeDesc, plantEquiTypeDesc, _, oclass, _).

            EquiCharacteristic(equiId, oclass, "UNICLASS_DESC", 1, S4String("")) :-
                SuperEquipWorkItem(equiId, _, _),
                AssetTypeDescription(equiId, plantTypeDesc, plantEquiTypeDesc),
                EquipmentMapping(plantTypeDesc, plantEquiTypeDesc, _, oclass, _).

        };
        solve (db <+> rules) project Equipment, EquiLongText, EquiCharacteristic


}
