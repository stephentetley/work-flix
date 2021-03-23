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

/// Note - Datalog produces a bag of answers, not a set.
/// If we are generating flocs from equipment we can expect duplicates

namespace FmpSkeleton/Rules {
    
    use AssetLib/Facts/SiteMapping.{SiteMapping};
    use AssetLib/AibRel/HierarchicalRelations.{AibFloc, AibEquipment};
    use AssetLib/S4Rel/Relations.{FlocDatum, FlocCharacteristic, EquiDatum, EquiCharacteristic};

    pub def equiRules[r](): #{EquiDatum, EquiCharacteristic, AibEquipment, SiteMapping, Status | r} = 
        eqDISTBD() <+> eqFSTNEM() <+> eqKISKKI() <+> eqNETWTL() <+> eqPODETU() <+> eqPSTNEM() 
            <+> eqEAST_NORTH() <+> eqAIB_REFERENCE()
    
    pub rel Status(aib: String, s4: String)

    /// Mapping is total.
    /// Don't map "DISPOSED OF"
    pub def status[r](): #{Status | r} = #{
        Status("OPERATIONAL", "OPER").
        Status("NON-OPERATIONAL", "NOP").
    }



    pub def eqDISTBD[r](): #{EquiDatum, EquiCharacteristic, AibEquipment, SiteMapping, Status | r} = 
        use AssetLib/Common/Utils.{properCaseName};
        #{
            EquiDatum(aibref, 
                            "E",
                            properCaseName(description),
                            "DIST",
                            installedFrom,
                            manufacturer,           
                            model,
                            partNumber,
                            stringWithDefault(serialNumber, "UNKNOWN"),
                            "${siteCode}-E-LV",
                            "",
                            pandi,
                            s4Status) :- 
                AibEquipment(aibref, aibSite, description, "EQUIPMENT: DISTRIBUTION BOARD", 
                    installedFrom, manufacturer, model, partNumber, serialNumber, _, pandi, status, _), 
                SiteMapping(aibSite, siteCode), 
                Status(status, s4Status).

            EquiCharacteristic(aibref, "DISTBD", "UNICLASS_CODE", "") :- 
                AibEquipment(aibref, _, _,  "EQUIPMENT: DISTRIBUTION BOARD", _, _,  _, _, _,  _, _, _,  _).

            EquiCharacteristic(aibref, "DISTBD", "UNICLASS_DESC", "") :- 
                AibEquipment(aibref, _, _,  "EQUIPMENT: DISTRIBUTION BOARD", _, _,  _, _, _,  _, _, _,  _).

        }


    pub def eqFSTNEM[r](): #{EquiDatum, EquiCharacteristic, AibEquipment, SiteMapping, Status | r} = 
        use AssetLib/Common/Utils.{properCaseName};
        #{
            EquiDatum(aibref, 
                            "I",
                            properCaseName(description),
                            "FSTN",
                            installedFrom,
                            manufacturer,           
                            model,
                            partNumber,
                            stringWithDefault(serialNumber, "UNKNOWN"),
                            "${siteCode}-PWD-PDM-PCO-SYS01",
                            "",
                            pandi,
                            s4Status) :- 
                AibEquipment(aibref, aibSite, description, "EQUIPMENT: MAGNETIC FLOW INSTRUMENT", 
                    installedFrom, manufacturer, model, partNumber, serialNumber, _, pandi, status, _), 
                SiteMapping(aibSite, siteCode), 
                Status(status, s4Status).

            EquiCharacteristic(aibref, "FSTNEM", "UNICLASS_CODE", "") :- 
                AibEquipment(aibref, _, _,  "EQUIPMENT: MAGNETIC FLOW INSTRUMENT", _, _,  _, _, _,  _, _, _,  _).

            EquiCharacteristic(aibref, "FSTNEM", "UNICLASS_DESC", "") :- 
                AibEquipment(aibref, _, _,  "EQUIPMENT: MAGNETIC FLOW INSTRUMENT", _, _,  _, _, _,  _, _, _,  _).

        }

    pub def eqKISKKI[r](): #{EquiDatum, EquiCharacteristic, AibEquipment, SiteMapping, Status | r} = 
        use AssetLib/Common/Utils.{properCaseName};
        #{
            EquiDatum(aibref, 
                            "C",
                            properCaseName(description),
                            "KISK",
                            installedFrom,
                            manufacturer,           
                            model,
                            partNumber,
                            stringWithDefault(serialNumber, "UNKNOWN"),
                            "${siteCode}-SIF-STM-BLG-SYS01",
                            "",
                            pandi,
                            s4Status) :- 
                AibEquipment(aibref, aibSite, description, "EQUIPMENT: KIOSK", 
                    installedFrom, manufacturer, model, partNumber, serialNumber, _, pandi, status, _),
                SiteMapping(aibSite, siteCode), 
                Status(status, s4Status).

            EquiCharacteristic(aibref, "KISKKI", "UNICLASS_CODE", "") :- 
                AibEquipment(aibref, _, _,  "EQUIPMENT: KIOSK", _, _,  _, _, _,  _, _, _,  _).

            EquiCharacteristic(aibref, "KISKKI", "UNICLASS_DESC", "") :- 
                AibEquipment(aibref, _, _,  "EQUIPMENT: KIOSK", _, _,  _, _, _,  _, _, _,  _).
        }

    pub def eqNETWTL[r](): #{EquiDatum, EquiCharacteristic, AibEquipment, SiteMapping, Status | r} = 
        use AssetLib/Common/Utils.{properCaseName};
        #{
            EquiDatum(aibref, 
                            "I",
                            properCaseName(description),
                            "NETW",
                            installedFrom,
                            manufacturer,           
                            model,
                            partNumber,
                            stringWithDefault(serialNumber, "UNKNOWN"),
                            "${siteCode}-CAA-NET-TEL-SYS01",
                            "",
                            pandi,
                            s4Status) :- 
                AibEquipment(aibref, aibSite, description, "EQUIPMENT: TELEMETRY OUTSTATION", 
                    installedFrom, manufacturer, model, partNumber, serialNumber, _, pandi, status, _), 
                SiteMapping(aibSite, siteCode), 
                Status(status, s4Status).

            EquiCharacteristic(aibref, "NETWTL", "UNICLASS_CODE", "") :- 
                AibEquipment(aibref, _, _,  "EQUIPMENT: TELEMETRY OUTSTATION", _, _,  _, _, _,  _, _, _,  _).

            EquiCharacteristic(aibref, "NETWTL", "UNICLASS_DESC", "") :- 
                AibEquipment(aibref, _, _,  "EQUIPMENT: TELEMETRY OUTSTATION", _, _,  _, _, _,  _, _, _,  _).
        }


    pub def eqPODETU[r](): #{EquiDatum, EquiCharacteristic, AibEquipment, SiteMapping, Status | r} = 
        use AssetLib/Common/Utils.{properCaseName};
        #{
            EquiDatum(aibref, 
                            "E",
                            properCaseName(description),
                            "PODE",
                            installedFrom,
                            manufacturer,           
                            model,
                            partNumber,
                            stringWithDefault(serialNumber, "UNKNOWN"),
                            "${siteCode}-CAA-NET-TEL-SYS01",
                            "",
                            pandi,
                            s4Status) :- 
                AibEquipment(aibref, aibSite, description, "EQUIPMENT: POWER SUPPLY", 
                    installedFrom, manufacturer, model, partNumber, serialNumber, _, pandi, status, _), 
                SiteMapping(aibSite, siteCode), 
                Status(status, s4Status).

            EquiCharacteristic(aibref, "PODETU", "UNICLASS_CODE", "") :- 
                AibEquipment(aibref, _, _,  "EQUIPMENT: POWER SUPPLY", _, _,  _, _, _,  _, _, _,  _).

            EquiCharacteristic(aibref, "PODETU", "UNICLASS_DESC", "") :- 
                AibEquipment(aibref, _, _,  "EQUIPMENT: POWER SUPPLY", _, _,  _, _, _,  _, _, _,  _).

        }

    pub def eqPSTNEM[r](): #{EquiDatum, EquiCharacteristic, AibEquipment, SiteMapping, Status | r} = 
        use AssetLib/Common/Utils.{properCaseName};
        #{
            EquiDatum(aibref, 
                            "I",
                            properCaseName(description),
                            "PSTN",
                            installedFrom,
                            manufacturer,           
                            model,
                            partNumber,
                            stringWithDefault(serialNumber, "UNKNOWN"),
                            "${siteCode}-PWD-PDM-PCO-SYS01",
                            "",
                            pandi,
                            s4Status) :- 
                AibEquipment(aibref, aibSite, description, "EQUIPMENT: PRESSURE INSTRUMENT", 
                    installedFrom, manufacturer, model, partNumber, serialNumber, _, pandi, status, _), 
                SiteMapping(aibSite, siteCode), 
                Status(status, s4Status).

            EquiCharacteristic(aibref, "PSTNDI", "UNICLASS_CODE", "") :- 
                AibEquipment(aibref, _, _,  "EQUIPMENT: PRESSURE INSTRUMENT", _, _,  _, _, _,  _, _, _,  _).

            EquiCharacteristic(aibref, "PSTNDI", "UNICLASS_DESC", "") :- 
                AibEquipment(aibref, _, _,  "EQUIPMENT: PRESSURE INSTRUMENT", _, _,  _, _, _,  _, _, _,  _).

        }


    pub def eqEAST_NORTH[r](): #{EquiCharacteristic, AibEquipment, EquiDatum | r} = 
        use AssetLib/Common/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        #{
            EquiCharacteristic(aibref, "EAST_NORTH", "EASTING", ToString.toString(eastingfromOsgb36(ngr)) ) :- 
                AibEquipment(aibref, _, _,  equiType, _, _,  _, _, _,  ngr, _, _,  _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _).

            EquiCharacteristic(aibref, "EAST_NORTH", "NORTHING", ToString.toString(northingfromOsgb36(ngr)) ) :- 
                AibEquipment(aibref, _, _,  _, _, _,  _, _, _,  ngr, _, _,  _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _).
        }

    pub def eqAIB_REFERENCE[r](): #{EquiCharacteristic, AibEquipment, EquiDatum | r} = 
        use AssetLib/Common/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        #{
            EquiCharacteristic(aibref, "AIB_REFERENCE", "AI2_AIB_REFERENCE", aibref) :- 
                AibEquipment(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _).

            EquiCharacteristic(aibref, "AIB_REFERENCE", "S4_AIB_REFERENCE", "") :- 
                AibEquipment(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _).
        }


    /// 
    /// # Flocs
    /// 


    pub def flocCAA[r](): #{FlocDatum, EquiDatum, EquiCharacteristic, AibEquipment, SiteMapping, Status | r} = 
        #{
            FlocDatum("${siteCode}-CAA", 
                            "Control and Automation",
                            "YW-GS",
                            "CAA",
                            installedFrom,           
                            false,
                            "UCON") :- 
                AibEquipment(_, aibSite, _, "EQUIPMENT: TELEMETRY OUTSTATION", 
                    installedFrom, _, _, _, _, _, _, _, _), 
                SiteMapping(aibSite, siteCode).
            

            FlocDatum("${siteCode}-CAA-NET", 
                            "Networks",
                            "YW-GS",
                            "NET",
                            installedFrom,           
                            false,
                            "UCON") :- 
                AibEquipment(_, aibSite, _, "EQUIPMENT: TELEMETRY OUTSTATION", 
                    installedFrom, _, _, _, _, _, _, _, _), 
                SiteMapping(aibSite, siteCode).
            
            FlocDatum("${siteCode}-CAA-NET-TEL", 
                            "Telemetry",
                            "YW-GS",
                            "TEL",
                            installedFrom,           
                            false,
                            "UCON") :- 
                AibEquipment(_, aibSite, _, "EQUIPMENT: TELEMETRY OUTSTATION", 
                    installedFrom, _, _, _, _, _, _, _, _), 
                SiteMapping(aibSite, siteCode).
            
            FlocDatum("${siteCode}-CAA-NET-TEL-SYS01", 
                            "Telemetry Outstation System",                            
                            "YW-GS",
                            "CTOS",
                            installedFrom,       
                            true,
                            "UCON") :- 
                AibEquipment(_, aibSite, _, "EQUIPMENT: TELEMETRY OUTSTATION", 
                    installedFrom, _, _, _, _, _, _, _, _), 
                SiteMapping(aibSite, siteCode).

        }
    /// Level 2
    pub def electricalPowerSupply[r](): #{FlocDatum, AibFloc, SiteMapping, Status | r} = #{
        FlocDatum("${siteCode}-E", "Electrical Power Supply", "YW-ES", "EPS", installedFrom, false, s4Status) :-
            AibFloc(sainumber, commonName, aibSite, "ELECTRICAL SERVICES", installedFrom, _),
            SiteMapping(aibSite, siteCode),
            Status(status, s4Status).
    }

    /// Level 3
    pub def lowVoltageDistribution[r](): #{FlocDatum, AibFloc, SiteMapping, Status | r} = #{
        FlocDatum("${siteCode}-E-LV", "Low Voltage Distribution", "YW-ES", "LVD", installedFrom, true, s4Status) :-
            AibFloc(sainumber, commonName, aibSite, "ELECTRICITY SUPPLY", installedFrom, _),
            SiteMapping(aibSite, siteCode),
            Status(status, s4Status).
    }



    def stringWithDefault(s: String, d: String): String = if (String.isEmpty(s)) d else s
    
    /// /// Never below 1970
    /// def date1OfYear(year: Int32): Time.LocalDate = 
    ///     let y1 = Int32.max(1970, year);
    ///     Time/LocalDate.new({dayOfMonth = 1, month = 1, year = y1})




    /// TODO - not AibEquipment
    pub def flEAST_NORTH[r](): #{FlocCharacteristic, AibEquipment | r} = 
        use AssetLib/Common/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        #{
            FlocCharacteristic(aibref, "EAST_NORTH", "EASTING", ToString.toString(eastingfromOsgb36(ngr)) ) :- 
                AibEquipment(aibref, _, _,  _, _, _,  _, _, _,  ngr, _, _,  _).

            FlocCharacteristic(aibref, "EAST_NORTH", "NORTHING", ToString.toString(northingfromOsgb36(ngr)) ) :- 
                AibEquipment(aibref, _, _,  _, _, _,  _, _, _,  ngr, _, _,  _).
        }




}
