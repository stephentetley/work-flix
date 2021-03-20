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


namespace FmpSkeleton/Rules {
    
    use AssetLib/Facts/SiteMapping.{SiteMapping};
    use AssetLib/S4Rel/Relations.{EquiDatum};

    /// TODO - move into a common lib...
    pub rel AibEquipment(aibref: String, 
                            aibSite : String, 
                            description: String, 
                            equipmentType: String, 
                            installedFrom: Time.LocalDate, 
                            manufacturer: String, 
                            model: String, 
                            partNumber: String, 
                            serialNumber: String, 
                            pandiNumber: String, 
                            status: String)

    pub def distdb[r](): #{EquiDatum, SiteMapping, Status | r} = #{
        EquiDatum(aibref, 
                        "E",              /// e.g "M", "I", "E"
                        description: String,
                        "DIST",
                        installedFrom,
                        manufacturer,           
                        model,
                        partNumber,
                        serialNumber,
                        "${siteCode}-E-LV",
                        "",
                        pandi,
                        s4Status) :- 
            AibEquipment(aibref, aibSite, description, "EQUIPMENT: DISTRIBUTION BOARD", installedFrom, manufacturer, model, partNumber, serialNumber, pandi, status), 
            SiteMapping(aibSite, siteCode), 
            Status(status, s4Status).

    }

    pub rel Status(aib: String, s4: String)

    /// Mapping is total.
    pub def status[r](): #{Status | r} = #{
        Status("OPERATIONAL", "OPER").
        Status("NON-OPERATIONAL", "NOP").
    }


}
