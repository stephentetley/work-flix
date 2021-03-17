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


namespace DwfOverflow/Rules {

    use AssetLib/Common/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
    use AssetLib/Facts/SiteMapping.{SiteMapping};
    use DwfOverflow/Relations.{AibSite, WorkListItem, Floc, FlocDatum, Characteristic};


    pub def level4Funcloc6x[r](): #{Floc, WorkListItem, SiteMapping, AibSite | r} = #{
        Floc(level4Floc6x(siteCode),"Flow Spilling", sainumber, "6XDWF OVERFLOW", 4, ngr, "FLS") :-
            WorkListItem(sainumber, commonName, assetType, aibSite),
            SiteMapping(aibSite, siteCode),
            AibSite(aibSite, _installedFrom, ngr),
            if is6XDWF(assetType).
    }

    pub def level5Funcloc6x[r](): #{Floc, WorkListItem, SiteMapping, AibSite | r} = #{
        Floc(level5Floc6x(siteCode),"6xDWF Overflow System", sainumber, "6XDWF OVERFLOW", 5, ngr, "SCIV") :-
            WorkListItem(sainumber, commonName, assetType, aibSite),
            SiteMapping(aibSite, siteCode),
            AibSite(aibSite, _installedFrom, ngr),
            if is6XDWF(assetType).
    }


    def level4Floc6x(siteCode: String): String = "${siteCode}-WWT-SOF-FLS"
    def level5Floc6x(siteCode: String): String = "${siteCode}-WWT-SOF-FLS-SYS01"

    def flocs[r](): #{Floc | r} = #{
        Floc("SITE1-WWT-SOF-FLS", "Flow Spilling", "SAI00075", "3XDWF OVERFLOW PROC", 4, "SE4652816720", "FLS").
        Floc("SITE1-WWT-SOF-FLS-SYS01", "6xDWF Overflow System", "SAI00076", "6XDWF OVERFLOW", 5, "SK4451594282", "SCIV").
    }

    def is3XDWF(s: String): Bool = String.startsWith(s, "3XDWF")

    def is6XDWF(s: String): Bool = String.startsWith(s, "6XDWF")

    def superior(s: String): String = 
        use Option.{flatMap};
        let step : Unit -> Option[String] = () -> {
            let* floc   = AssetLib/S4/Base/Floc.new(s);
            let* sup    = AssetLib/S4/Base/Floc.parent(floc);
            Some(ToString.toString(sup))
        };
        Option.getWithDefault(step(), "")


    /// FlocData

    pub def getFlocData[r](): #{ FlocDatum | r } = 
        project FlocDatum solve (flocDatum() <+> flocs())


    def flocDatum[r](): #{FlocDatum, Floc | r} = #{
        FlocDatum(floc, floc, description, level, "YW-GS", 
                    objType, defaultDate(), 2100, 2100, 1000, superior(floc), level >= 5, "ZFLOCST", "UCON") :- 
            Floc(floc, description, _, _, level, _, objType).
    }


    def defaultDate(): Time.LocalDate = Time/LocalDate.new({dayOfMonth = 1, month = 1, year = 1970})

    /// Characteristics
    pub def getCharacteristics[r](): #{ Characteristic | r } = 
        let db = { 
            ai2AibReference() <+> s4AibReference() <+> easting() <+> northing() <+> systemType() 
                    <+> uniclassCode() <+> uniclassDesc() <+> flocs()
        };
        project Characteristic solve db
        

    def ai2AibReference[r](): #{Characteristic, Floc | r} = #{
        Characteristic(floc, "003", "AIB_REFERENCE", 1, "AI2_AIB_REFERENCE", sainum) :- 
            Floc(floc, _, sainum, _, _, _, _).
    }

    def s4AibReference[r](): #{Characteristic, Floc | r} = #{
        Characteristic(floc, "003", "AIB_REFERENCE", 1, "S4_AIB_REFERENCE", "") :- 
            Floc(floc, _, _, _, _, _, _).
    }

    def easting[r](): #{Characteristic, Floc | r} = #{
        Characteristic(floc, "003", "EAST_NORTH", 1, "EASTING", ToString.toString(eastingfromOsgb36(ngr)) ) :- 
            Floc(floc, _, _, _, _, ngr, _).
    }

    def northing[r](): #{Characteristic, Floc | r} = #{
        Characteristic(floc, "003", "EAST_NORTH", 1, "NORTHING", ToString.toString(northingfromOsgb36(ngr)) ) :- 
            Floc(floc, _, _, _, _, ngr, _).
    }

    def systemType[r](): #{Characteristic, Floc | r} = #{
        Characteristic(floc, "003", "SCIVCS", 1, "SYSTEM_TYPE", if(is3XDWF(overflow)) "3 X DWF OVERFLOW" else "6 X DWF OVERFLOW") :- 
            Floc(floc, _, _, overflow, level, _, _), 
            if level == 5.
    }
        
    def uniclassCode[r](): #{Characteristic, Floc | r} = #{
        Characteristic(floc, "003", "UNICLASS_CODE", 1, "UNICLASS_CODE", "") :- 
            Floc(floc, _, _, _, level, _, _), 
            if level != 5.
    }

    def uniclassDesc[r](): #{Characteristic, Floc | r} = #{
        Characteristic(floc, "003", "UNICLASS_CODE", 1, "UNICLASS_DESC", "") :- 
            Floc(floc, _, _, _, level, _, _), 
            if level != 5.
    }

}
