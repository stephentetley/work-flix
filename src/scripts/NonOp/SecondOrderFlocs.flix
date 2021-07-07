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

/// "ACH" Flocs for existing sites.

namespace AssetScripts/NonOp/SecondOrderFlocs {

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/S4Lite/Datatypes.{UxlSource};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/GenS4/S4LiteRelations.{FunctionalLocation, FlocCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Date, S4Int, S4Float};
    use AssetScripts/NonOp/Relations.{SecondOrderFlocWorkItem, SiteFloc, SiteEastNorth};

    /// TODO - must split worklist `worklist: XlsxSource, `
                        

    pub def genFlocUxl(db: #{SecondOrderFlocWorkItem, SiteFloc, SiteEastNorth, FunctionalLocation, FlocCharacteristic | r},  
                        args: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let solns       = genFlocs(db);
        let s4lite      = genS4Lite(solns);
        let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(args, s4lite);
        Ok()


    pub def genFlocs(db: #{SecondOrderFlocWorkItem, SiteFloc, SiteEastNorth, 
                            FunctionalLocation, FlocCharacteristic | r}): #{FunctionalLocation, FlocCharacteristic | r} = 
        let rules = #{

            FunctionalLocation("${sitefloc}-ACH", "Archive", "YW-GS", "ACH", defaultDate(), false, "UCON") :- 
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).
            
            FunctionalLocation("${sitefloc}-ACH-ACH", "Archive", "YW-GS", "ACH", defaultDate(), false, "UCON") :- 
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).

            FunctionalLocation("${sitefloc}-ACH-ACH-ACH", "Archive", "YW-GS", "ACH", defaultDate(), false, "UCON") :- 
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).

            FunctionalLocation("${sitefloc}-ACH-ACH-ACH-NON01", "Archive", "YW-GS", "ACH", defaultDate(), true, "UCON") :- 
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).

            /// AIB_REFERENCE

            FlocCharacteristic("${sitefloc}-ACH", "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(aibSiteRef)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).
            
            FlocCharacteristic("${sitefloc}-ACH", "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).

            FlocCharacteristic("${sitefloc}-ACH-ACH", "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(aibSiteRef)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).
            
            FlocCharacteristic("${sitefloc}-ACH-ACH", "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).

            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH", "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(aibSiteRef)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).
            
            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH", "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).

            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH-NON01", "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(aibSiteRef)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).
            
            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH-NON01", "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).

            /// UNICLASS_CODE (Don't generate...)

            /// EAST_NORTH

            FlocCharacteristic("${sitefloc}-ACH", "EAST_NORTH", "EASTING", 1, S4Int(easting)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc),
                SiteEastNorth(sitefloc, easting, _).
            
            FlocCharacteristic("${sitefloc}-ACH", "EAST_NORTH", "NORTHING", 1, S4Int(northing)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc),
                SiteEastNorth(sitefloc, _, northing).
            
            FlocCharacteristic("${sitefloc}-ACH-ACH", "EAST_NORTH", "EASTING", 1, S4Int(easting)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc),
                SiteEastNorth(sitefloc, easting, _).
            
            FlocCharacteristic("${sitefloc}-ACH-ACH", "EAST_NORTH", "NORTHING", 1, S4Int(northing)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc),
                SiteEastNorth(sitefloc, _, northing).

            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH", "EAST_NORTH", "EASTING", 1, S4Int(easting)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc),
                SiteEastNorth(sitefloc, easting, _).
            
            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH", "EAST_NORTH", "NORTHING", 1, S4Int(northing)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc),
                SiteEastNorth(sitefloc, _, northing).

            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH-NON01", "EAST_NORTH", "EASTING", 1, S4Int(easting)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc),
                SiteEastNorth(sitefloc, easting, _).

            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH-NON01", "EAST_NORTH", "NORTHING", 1, S4Int(northing)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc),
                SiteEastNorth(sitefloc, _, northing).
        };
        solve (db <+> rules) project FunctionalLocation, FlocCharacteristic

    def defaultDate(): Time.LocalDate = Time/LocalDate.new({year = 1970, month = 1, dayOfMonth = 1})


    def genS4Lite(relns: #{FunctionalLocation, FlocCharacteristic | r}): UxlSource & Impure = 
        { funclocs = AssetLib/GenS4/S4LiteRelations.toSLFunctionalLocation(relns)
        , funclocLongTexts = Monoid.empty()
        , funclocCharacteristics = AssetLib/GenS4/S4LiteRelations.toSLFlocCharacteristic(relns)
        , equipment = Monoid.empty()
        , equiLongTexts = Monoid.empty()
        , equiCharacteristics = Monoid.empty()
        }


}
