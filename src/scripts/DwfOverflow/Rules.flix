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

    use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
    use AssetLib/Facts/SiteMapping.{SiteMapping};
    use DwfOverflow/Relations.{AibSite, WorkListItem, Floc, FlocDatum, Characteristic, ExistingFloc,
        FreeSettlementSysIndex, OverflowType};
    use DwfOverflow/Relations.OverflowType.{X3_DWF, X6_DWF};

    pub def loadFileData[r](worklistSheetName: String, 
                            worklist: System.FilePath, 
                            siteMappingFile: System.FilePath, 
                            allSitesFile: System.FilePath,
                            sysFlocFile: System.FilePath,
                            flocFiles: List[System.FilePath]): Result[#{WorkListItem, SiteMapping, AibSite, ExistingFloc, FreeSettlementSysIndex | r}, String] & Impure = 
        use Result.{flatMap};
        let* r1 = DwfOverflow/Rules/ExcelLoader.readWorkList(worklistSheetName, worklist);
        let* r2 = AssetLib/Facts/SiteMapping.getSiteMapping(siteMappingFile);
        let* r3 = DwfOverflow/Rules/ExcelLoader.readAibSites(allSitesFile);
        let* r4 = DwfOverflow/Rules/TransferFileLoader.readSysFlocTransferFile(sysFlocFile);
        let _   = Console.printLine("FreeSettlementSysIndex...");
        let _   = r4 |> unsafeToString |> println;
        let* r5 = loadFlocTransferFiles(flocFiles);
        Ok(r1 <+> r2 <+> r3 <+> r4 <+> r5)

    def loadFlocTransferFiles[r](srcs: List[System.FilePath]): Result[#{ExistingFloc | r}, String] & Impure = 
        use Result.{flatMap};
        let* xs     = Result.traverse(DwfOverflow/Rules/TransferFileLoader.readFlocTransferFile, srcs);
        let relns   = RelLib/Relation.combineAll(xs);
        Ok(relns)



    /// 6xDWF


    pub def get3xDwfFlocs[r](db: #{Floc, WorkListItem, SiteMapping, AibSite, ExistingFloc, FreeSettlementSysIndex | r}): #{ Floc | r } = 
        solve (level5Funcloc3x() <+> db) project Floc 


    def level5Funcloc3x[r](): #{Floc, WorkListItem, SiteMapping, AibSite, FreeSettlementSysIndex | r} = #{
        Floc(level5Floc3x(siteCode, sysIx),"3xDWF Overflow System", sainumber, X3_DWF, 5, ngr, "SCIV", constrYear) :-
            WorkListItem(sainumber, commonName, assetType, aibSite),
            SiteMapping(aibSite, siteCode),
            AibSite(aibSite, constrYear, ngr),
            FreeSettlementSysIndex(siteCode, sysIx),
            if is3XDWF(assetType).
    }

    def is3XDWF(s: String): Bool = String.startsWith(s, "3XDWF")
    
    def level5Floc3x(siteCode: String, ix: Int32): String = 
        let ixs = String.padLeft(2, '0', Int32.toString(ix));
        "${siteCode}-WWT-SOF-SET-SYS${ixs}"

    /// 6xDWF

    pub def get6xDwfFlocs[r](db: #{Floc, WorkListItem, SiteMapping, AibSite, ExistingFloc | r}): #{ Floc | r } = 
        solve (level3Funcloc6x() <+> level4Funcloc6x() <+> level5Funcloc6x() <+> db) project Floc 

    def level3Funcloc6x[r](): #{Floc, WorkListItem, SiteMapping, AibSite, ExistingFloc | r} = #{
        Floc(level3Floc6x(siteCode), "Storm Overflow", sainumber, X6_DWF, 3, ngr, "SOF", constrYear) :-
            WorkListItem(sainumber, commonName, assetType, aibSite),
            SiteMapping(aibSite, siteCode),
            AibSite(aibSite, constrYear, ngr),
            not ExistingFloc(siteCode, "WWT-SOF"),
            if is6XDWF(assetType).
    }

    def level4Funcloc6x[r](): #{Floc, WorkListItem, SiteMapping, AibSite | r} = #{
        Floc(level4Floc6x(siteCode), "Flow Spilling", sainumber, X6_DWF, 4, ngr, "FLS", constrYear) :-
            WorkListItem(sainumber, commonName, assetType, aibSite),
            SiteMapping(aibSite, siteCode),
            AibSite(aibSite, constrYear, ngr),
            if is6XDWF(assetType).
    }

    def level5Funcloc6x[r](): #{Floc, WorkListItem, SiteMapping, AibSite | r} = #{
        Floc(level5Floc6x(siteCode),"6xDWF Overflow System", sainumber, X6_DWF, 5, ngr, "SCIV", constrYear) :-
            WorkListItem(sainumber, commonName, assetType, aibSite),
            SiteMapping(aibSite, siteCode),
            AibSite(aibSite, constrYear, ngr),
            if is6XDWF(assetType).
    }

    
    def is6XDWF(s: String): Bool = String.startsWith(s, "6XDWF")

    def level3Floc6x(siteCode: String): String = "${siteCode}-WWT-SOF"
    def level4Floc6x(siteCode: String): String = "${siteCode}-WWT-SOF-FLS"
    def level5Floc6x(siteCode: String): String = "${siteCode}-WWT-SOF-FLS-SYS01"


    def superior(s: String): String = 
        use Option.{flatMap};
        let step : Unit -> Option[String] = () -> {
            let* floc   = AssetLib/Base/S4/Floc.new(s);
            let* sup    = AssetLib/Base/S4/Floc.parent(floc);
            Some(ToString.toString(sup))
        };
        Option.getWithDefault(step(), "")


    /// FlocData

    pub def getFlocData[r](db: #{Floc, FlocDatum | r}): #{ FlocDatum | r } = 
        project FlocDatum solve (flocDatum() <+> db)


    def flocDatum[r](): #{FlocDatum, Floc | r} = #{
        FlocDatum(floc, floc, description, level, "YW-GS", 
                    objType, date1OfYear(year), 2100, 2100, 1000, superior(floc), level >= 5, "ZFLOCST", "UCON") :- 
            Floc(floc, description, _, _, level, _, objType, year).
    }

    /// Never below 1970
    def date1OfYear(year: Int32): Time.LocalDate = 
        let y1 = Int32.max(1970, year);
        Time/LocalDate.new({dayOfMonth = 1, month = 1, year = y1})

    /// Characteristics
    pub def getCharacteristics[r](db: #{Floc, Characteristic | r}): #{ Characteristic | r } = 
        let goal = { 
            ai2AibReference() <+> s4AibReference() <+> easting() <+> northing() <+> systemType() 
                    <+> uniclassCode() <+> uniclassDesc() <+> db
        };
        project Characteristic solve goal
        

    def ai2AibReference[r](): #{Characteristic, Floc | r} = #{
        Characteristic(floc, "003", "AIB_REFERENCE", 1, "AI2_AIB_REFERENCE", sainum) :- 
            Floc(floc, _, sainum, _, _, _, _, _).
    }

    def s4AibReference[r](): #{Characteristic, Floc | r} = #{
        Characteristic(floc, "003", "AIB_REFERENCE", 1, "S4_AIB_REFERENCE", "") :- 
            Floc(floc, _, _, _, _, _, _, _).
    }

    def easting[r](): #{Characteristic, Floc | r} = #{
        Characteristic(floc, "003", "EAST_NORTH", 1, "EASTING", ToString.toString(eastingfromOsgb36(ngr)) ) :- 
            Floc(floc, _, _, _, _, ngr, _, _).
    }

    def northing[r](): #{Characteristic, Floc | r} = #{
        Characteristic(floc, "003", "EAST_NORTH", 1, "NORTHING", ToString.toString(northingfromOsgb36(ngr)) ) :- 
            Floc(floc, _, _, _, _, ngr, _, _).
    }

    def systemType[r](): #{Characteristic, Floc | r} = #{
        Characteristic(floc, "003", "SCIVCS", 1, "SYSTEM_TYPE", "3 X DWF OVERFLOW") :- 
            Floc(floc, _, _, X3_DWF, 5, _, _, _).

        Characteristic(floc, "003", "SCIVCS", 1, "SYSTEM_TYPE", "6 X DWF OVERFLOW") :- 
            Floc(floc, _, _, X6_DWF, 5, _, _, _).
    }
        
    def uniclassCode[r](): #{Characteristic, Floc | r} = #{
        Characteristic(floc, "003", "UNICLASS_CODE", 1, "UNICLASS_CODE", "") :- 
            Floc(floc, _, _, _, level, _, _, _), 
            if level != 5.
    }

    def uniclassDesc[r](): #{Characteristic, Floc | r} = #{
        Characteristic(floc, "003", "UNICLASS_CODE", 1, "UNICLASS_DESC", "") :- 
            Floc(floc, _, _, _, level, _, _, _), 
            if level != 5.
    }

}
