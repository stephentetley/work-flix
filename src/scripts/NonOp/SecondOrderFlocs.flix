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

    use AssetLib/GenS4/S4LiteRelations.{FunctionalLocation, FlocCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Date, S4Int, S4Float};
    use AssetScripts/NonOp/Relations.{SecondOrderFlocWorkItem, SiteFloc};

    pub def genFlocs(db: #{SecondOrderFlocWorkItem, SiteFloc, FunctionalLocation, FlocCharacteristic | r}): #{FunctionalLocation, FlocCharacteristic | r} = 
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

            /// UNICLASS_CODE

            FlocCharacteristic("${sitefloc}-ACH", "UNICLASS_CODE", "UNICLASS_CODE", 1, S4String(aibSiteRef)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).
            
            FlocCharacteristic("${sitefloc}-ACH", "UNICLASS_DESC", "UNICLASS_CODE", 1, S4String("")) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).

            FlocCharacteristic("${sitefloc}-ACH-ACH", "UNICLASS_CODE", "UNICLASS_CODE", 1, S4String(aibSiteRef)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).
            
            FlocCharacteristic("${sitefloc}-ACH-ACH", "UNICLASS_DESC", "UNICLASS_CODE", 1, S4String("")) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).

            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH", "UNICLASS_CODE", "UNICLASS_CODE", 1, S4String(aibSiteRef)) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).
            
            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH", "UNICLASS_DESC", "UNICLASS_CODE", 1, S4String("")) :-
                SecondOrderFlocWorkItem(aibSiteRef), 
                SiteFloc(aibSiteRef, sitefloc).

            /// FlocCharacteristic("${sitefloc}-ACH-ACH-ACH-NON01", "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(aibSiteRef)) :-
            ///     SecondOrderFlocWorkItem(aibSiteRef), 
            ///     SiteFloc(aibSiteRef, sitefloc).
            
            /// FlocCharacteristic("${sitefloc}-ACH-ACH-ACH-NON01", "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
            ///     SecondOrderFlocWorkItem(aibSiteRef), 
            ///     SiteFloc(aibSiteRef, sitefloc).                

        };
        solve (db <+> rules) project FunctionalLocation, FlocCharacteristic

    def defaultDate(): Time.LocalDate = Time/LocalDate.new({year = 1970, month = 1, dayOfMonth = 1})

}
