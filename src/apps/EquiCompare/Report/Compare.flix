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

namespace EquiCompare/Report/Compare {

    use EquiCompare/Report/Relations.{AibEquipment, S4Equipment, SiteMap};

    rel Synced(pliReference: String, s4EquiId: String, commonName: String, description: String)

    rel NotMigrated(pliReference: String, site: String, commonName: String)

    rel Orphaned(s4EquiId: String, site: String, description: String)
    
    pub def synced[r](): #{ Synced, AibEquipment, S4Equipment, SiteMap | r } = #{ 
        Synced(reference, equiId, commonName, description) :- 
            AibEquipment(reference, commonName, siteAib, installDate, manufacturer, _, serialNumber),
            SiteMap(siteAib, siteS4),
            S4Equipment(equiId, description, siteS4, installDate, manufacturer, _, serialNumber).
    }

    pub def notMigrated[r](): #{ NotMigrated, AibEquipment, S4Equipment, SiteMap | r } = #{ 
        NotMigrated(reference, siteAib, commonName) :- 
            AibEquipment(reference, commonName, siteAib, installDate, manufacturer, _, serialNumber),
            SiteMap(siteAib, siteS4),
            not S4Equipment(_, _, siteS4, installDate, manufacturer, _, serialNumber).
    }

    pub def orphaned[r](): #{ Orphaned, AibEquipment, S4Equipment, SiteMap | r } = #{ 
        Orphaned(equiId, siteS4, description) :- 
            S4Equipment(equiId, description, siteS4, installDate, manufacturer, _, serialNumber),
            SiteMap(siteAib, siteS4),
            not AibEquipment(_, _, siteAib, installDate, manufacturer, _, serialNumber).    
    }

}
