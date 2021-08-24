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

namespace AssetScripts/NonOp/AchFlocs {

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/S4Lite/Datatypes.{UxlSource, SLFunctionalLocation};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Date, S4Int, S4Float};
    use AssetLib/GenS4/WorkLists.{FlocWorkItem};

    /// Split worklist...
                        
    pub def genFlocUxl(src: XlsxSource, 
                        args: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* items      = AssetLib/GenS4/WorkLists.readFlocWorkList(src);
        let worklists   = AssetScripts/NonOp/Utils.sublists(50, items);
        let* _          = Result.foldLeftM((ac, xs) -> genFlocUxl1(ac, xs, args), 1, worklists);
        Ok()


    pub rel InstallationWorkItem(sainum: String)

    def genFlocUxl1(i: Int32, 
                    xs: List[FlocWorkItem],
                    args: UxlOutputArgs): Result[Int32, String] & Impure = 
        use Result.{flatMap};
        let workitems   = Relation.foldMap(x1 -> #{ SiteWorkItem(x1.funcloc, x1.gridRef). }, xs);
        let solns       = genFlocs(workitems);
        let s4lite      = genS4Lite(solns);
        let args1       = AssetScripts/NonOp/Utils.updateArgs(i, args);
        let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(false, args1, s4lite);
        Ok(i + 1)


    /// Use a custom relation for FunctionalLocation.
    /// 
    pub rel FunctionalLocation(funcloc: String, description: String, structureInd: String, objType: String, equiInstall: Bool)

    pub rel SiteWorkItem(siteFloc: String, ngr: String)




    pub def genFlocs(db: #{SiteWorkItem,
                            FunctionalLocation, FlocCharacteristic | r}): #{FunctionalLocation, FlocCharacteristic | r} = 
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        let easting = eastingfromOsgb36 >> S4Int;
        let northing = northingfromOsgb36 >> S4Int;
        let rules = #{

            FunctionalLocation("${sitefloc}-ACH", "Archive", "YW-GS", "ACH", false) :- 
                SiteWorkItem(sitefloc, _).
            
            FunctionalLocation("${sitefloc}-ACH-ACH", "Archive", "YW-GS", "ACH", false) :- 
                SiteWorkItem(sitefloc, _).

            FunctionalLocation("${sitefloc}-ACH-ACH-ACH", "Archive", "YW-GS", "ACH", false) :- 
                SiteWorkItem(sitefloc, _).

            FunctionalLocation("${sitefloc}-ACH-ACH-ACH-NON01", "Archive", "YW-GS", "ACH", true) :-
                SiteWorkItem(sitefloc, _).

            /// AIB_REFERENCE - just S4_AIB_REFERENCE
            
            FlocCharacteristic("${sitefloc}-ACH", "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
                SiteWorkItem(sitefloc, _).

            
            FlocCharacteristic("${sitefloc}-ACH-ACH", "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
                SiteWorkItem(sitefloc, _).

            
            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH", "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
                SiteWorkItem(sitefloc, _).
            
            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH-NON01", "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
                SiteWorkItem(sitefloc, _).

            /// UNICLASS_CODE (Don't generate...)

            /// EAST_NORTH

            FlocCharacteristic("${sitefloc}-ACH", "EAST_NORTH", "EASTING", 1, easting(ngr)) :-
                SiteWorkItem(sitefloc, ngr).
            
            FlocCharacteristic("${sitefloc}-ACH", "EAST_NORTH", "NORTHING", 1, northing(ngr)) :-
                SiteWorkItem(sitefloc, ngr).
            
            FlocCharacteristic("${sitefloc}-ACH-ACH", "EAST_NORTH", "EASTING", 1, easting(ngr)) :-
                SiteWorkItem(sitefloc, ngr).
            
            FlocCharacteristic("${sitefloc}-ACH-ACH", "EAST_NORTH", "NORTHING", 1, northing(ngr)) :-
                SiteWorkItem(sitefloc, ngr).

            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH", "EAST_NORTH", "EASTING", 1, easting(ngr)) :-
                SiteWorkItem(sitefloc, ngr).
            
            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH", "EAST_NORTH", "NORTHING", 1, northing(ngr)) :-
                SiteWorkItem(sitefloc, ngr).

            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH-NON01", "EAST_NORTH", "EASTING", 1, easting(ngr)) :-
                SiteWorkItem(sitefloc, ngr).

            FlocCharacteristic("${sitefloc}-ACH-ACH-ACH-NON01", "EAST_NORTH", "NORTHING", 1, northing(ngr)) :-
                SiteWorkItem(sitefloc, ngr).
        };
        solve (db <+> rules) project FunctionalLocation, FlocCharacteristic

    


    def genS4Lite(relns: #{FunctionalLocation, FlocCharacteristic | r}): UxlSource & Impure = 
        { funclocs = toSLFunctionalLocation(relns)
        , funclocLongTexts = Monoid.empty()
        , funclocCharacteristics = AssetLib/S4Lite/S4LiteRelations.toSLFlocCharacteristic(relns)
        , equipment = Monoid.empty()
        , equiLongTexts = Monoid.empty()
        , equiCharacteristics = Monoid.empty()
        }


    def toSLFunctionalLocation(src: #{FunctionalLocation | r}): Chain[SLFunctionalLocation] & Impure = 
        query src select (x1, x2, x3, x4, x5) from FunctionalLocation(x1, x2, x3, x4, x5)
            |> Chain.fromArray
            |> Chain.map(functionalLocationToS4Lite)


    def functionalLocationToS4Lite(x: (String, String, String, String, Bool)): SLFunctionalLocation = 
        let (x1, x2, x3, x4, x5) = x;
        let floc                = AssetLib/Base/S4/Floc.new(x1);
        let defaultDate         = Time/LocalDate.new({year = 1970, month = 1, dayOfMonth = 1});
        { funcloc               = x1
        , description           = x2
        , category              = Result.getWithDefault(Result.map(AssetLib/Base/S4/Floc.level, floc), 0)
        , structureIndicator    = x3
        , objectType            = x4
        , startupDate           = defaultDate
        , superiorFloc          = Result.getWithDefault(Result.map(AssetLib/Base/S4/Floc.pop >> ToString.toString, floc), "")
        , equipmentInstall      = x5
        , status                = "UCON"
        }


}
