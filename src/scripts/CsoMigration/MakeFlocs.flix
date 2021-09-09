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

/// Make Flocs for existing "largest" to "SYS01".

namespace CsoMigration/MakeFlocs {

    use SheetIO/Reader.{XlsxSource};
    use SheetIO.NamedRowEvaluator;
    use AssetLib/S4Lite/Datatypes.{UxlSource, SLFunctionalLocation};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue;
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Date, S4Int, S4Float};
    use AssetLib/GenS4/WorkLists.{FlocWorkItem};

    /// Split worklist...
    

    pub def genFlocUxl(src: XlsxSource, 
                        args: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* items      = readTempWorkItems(src);
        let worklists   = sublists(63, items);
        let* _          = Result.foldLeftM((ac, xs) -> genFlocUxl1(ac, xs, args), 1, worklists);
        Ok()


    def genFlocUxl1(i: Int32, 
                    xs: List[TempWorkItem],
                    args: UxlOutputArgs): Result[Int32, String] & Impure = 
        use Result.{flatMap};
        let workitems   = RelLib/Relation.foldMap(x1 -> 
                            #{ WorkItem(x1.site, x1.commonName, x1.level, x1.proctype, x1.ngr, x1.installedDate). }, xs);
        let solns       = genFlocs(workitems);
        let s4lite      = genS4Lite(solns);
        let args1       = updateArgs(i, args);
        let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(false, args1, s4lite);
        Ok(i + 1)




    /// Use a custom relation for FunctionalLocation.
    /// 
    pub rel FunctionalLocation(funcloc: String, description: String, structureInd: String, objType: String, installedDate: Time.LocalDate, equiInstall: Bool)

    /// Record versoin so we can use sublists
    type alias TempWorkItem = 
        { site: String
        , commonName: String
        , level: Int32
        , proctype: String
        , ngr: String
        , installedDate: Time.LocalDate
        }

    pub rel WorkItem(site: String, commonName: String, level: Int32, proctype: String, ngr: String, installedDate: Time.LocalDate)


    def systemDescription(commonName: String): CharValue = match commonName { 
        case s if s `String.contains` "CSO" => S4String("COMBINED SEWER OVERFLOW")
        case s if s `String.contains` "HLR" => S4String("HIGH LEVEL RELIEF")
        case s if s `String.contains` "SCC" => S4String("SCREENING CHAMBER")
        case _ => S4String("UNKNOWN")
    }

    pub def genFlocs(db: #{WorkItem,
                            FunctionalLocation, FlocCharacteristic | r}): #{FunctionalLocation, FlocCharacteristic | r} = 
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        let easting = eastingfromOsgb36 >> S4Int;
        let northing = northingfromOsgb36 >> S4Int;
        let rules = #{

            /// Level 2
            FunctionalLocation("${site}-WTN", "Waste Water Transmission", "YW-GS", "WTN", insDate, false) :- 
                WorkItem(site, _, level, _, _, insDate), 
                if level == 1.
            
            /// Level 3
            FunctionalLocation("${site}-WTN-SOF", "Storm Overflow", "YW-GS", "SOF", insDate, false) :- 
                WorkItem(site, _, level, _, _, insDate), 
                if level < 3. 

            
            /// Level 4
            FunctionalLocation("${site}-WTN-SOF-FLA", "Flow Attenuation", "YW-GS", "SOF", insDate, false) :- 
                WorkItem(site, _, level, "FLA", _, insDate), 
                if level < 4. 

            FunctionalLocation("${site}-WTN-SOF-FLS", "Flow Spilling", "YW-GS", "SOF", insDate, false) :- 
                WorkItem(site, _, level, "FLS", _, insDate), 
                if level < 4. 

            /// Level 5
            FunctionalLocation("${site}-WTN-SOF-${proctype}-SYS01", commonName, "YW-GS", "SCIV", insDate, true) :- 
                WorkItem(site, commonName, level, proctype, _, insDate),
                if level < 5.



            /// AIB_REFERENCE - just S4_AIB_REFERENCE - forall new flocs
            
            FlocCharacteristic(floc, "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
                FunctionalLocation(floc, _, _, _, _, _).


            /// UNICLASS_CODE (Don't generate...)

            /// EAST_NORTH

            FlocCharacteristic(floc, "EAST_NORTH", "EASTING", 1, easting(ngr)) :-
                FunctionalLocation(floc, _, _, _, _, _),
                WorkItem(site, _, level, "FLS", ngr, _),
                if floc `String.startsWith` site. 
            
            FlocCharacteristic(floc, "EAST_NORTH", "NORTHING", 1, northing(ngr)) :-
                FunctionalLocation(floc, _, _, _, _, _),
                WorkItem(site, _, level, "FLS", ngr, _),
                if floc `String.startsWith` site. 


            FlocCharacteristic(floc, "SCIVSY", "SYSTEM_TYPE", 1, systemDescription(commonName)) :-
                FunctionalLocation(floc, _, _, "SCIV", _, _),
                WorkItem(site, commonName, _, _, _, _),
                if floc `String.startsWith` site. 

        };
        solve (db <+> rules) project FunctionalLocation, FlocCharacteristic

    


    def genS4Lite(relns: #{FunctionalLocation, FlocCharacteristic | r}): UxlSource & Impure = 
        { funclocs = toSLFunctionalLocation(relns)
        , funclocLongTexts = Monoid.empty()
        , funclocCharacteristics = AssetLib/S4Lite/S4LiteRelations.toSLFlocCharacteristics(relns) |> Chain.fromArray
        , equipment = Monoid.empty()
        , equiLongTexts = Monoid.empty()
        , equiCharacteristics = Monoid.empty()
        }


    def toSLFunctionalLocation(src: #{FunctionalLocation | r}): Chain[SLFunctionalLocation] & Impure = 
        query src select (x1, x2, x3, x4, x5, x6) from FunctionalLocation(x1, x2, x3, x4, x5, x6)
            |> Chain.fromArray
            |> Chain.map(functionalLocationToS4Lite)


    def functionalLocationToS4Lite(x: (String, String, String, String, Time.LocalDate, Bool)): SLFunctionalLocation = 
        let (x1, x2, x3, x4, x5, x6) = x;
        let floc                = AssetLib/Base/S4/Floc.new(x1);
        { funcloc               = x1
        , description           = x2
        , category              = Result.getWithDefault(Result.map(AssetLib/Base/S4/Floc.level, floc), 0)
        , structureIndicator    = x3
        , objectType            = x4
        , startupDate           = x5
        , superiorFloc          = Result.getWithDefault(Result.map(AssetLib/Base/S4/Floc.pop >> ToString.toString, floc), "")
        , equipmentInstall      = x6
        , status                = "UCON"
        }

    pub def readTempWorkItems(src: XlsxSource): Result[List[TempWorkItem], String] & Impure =
        SheetIO/Reader.readAllNamedRows(src, evalTempWorkItem())

    def evalTempWorkItem(): NamedRowEvaluator[TempWorkItem] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getInt32Named, getLocalDateNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6) ->
            { site = String.take(5, x1)
            , commonName = x2
            , level = x3
            , proctype = x4
            , ngr = x5
            , installedDate = x6
            })
            <&> getTrimmedContentNamed("Largest Floc")
            <*> getTrimmedContentNamed("Common Name")
            <*> getInt32Named("Existing Floc Level")
            <*> getTrimmedContentNamed("Level4")
            <*> getTrimmedContentNamed("NGR")
            <*> getLocalDateNamed("Installed Date")


    pub def updateArgs(i: Int32, args: UxlOutputArgs): UxlOutputArgs = 
        let newName = String.replace("##", ToString.toString(i), args.changeRequestName);
        let newPath = mapBaseName(args.outpath, s -> String.replace("##", ToString.toString(i), s));
        { changeRequestName = newName
        , outpath = newPath
        , uxlTemplate = args.uxlTemplate
        }

    /// For System.FilePath...
    def mapBaseName(path: System.FilePath, fn: String -> String): System.FilePath = 
        match System/FilePath.getBaseName(path) {
            case Some(name1) => System/FilePath.putBaseName(path, fn(name1))
            case None => path
        }



    pub def sublists(n: Int32, xs: List[a]): List[List[a]] = 
        if (n < 1)
            Nil
        else 
            sublistsHelper(n, 0, xs, ks -> ks, ls -> ls)

    pub def sublistsHelper(n: Int32, i: Int32, xs: List[a], k1: List[a] -> List[a], k2: List[List[a]] -> List[List[a]]): List[List[a]] =
        match xs { 
            case Nil => match k1(Nil) { 
                case Nil => k2(Nil)
                case ks => k2(ks :: Nil)
            }
            case x1 :: rs => {
                if (i >= n) 
                    sublistsHelper(n, 1, rs, ks -> x1 :: ks, ls -> k2(k1(Nil) :: ls))
                else 
                    sublistsHelper(n, i + 1, rs, ks -> k1(x1 :: ks), k2)
            }
        }

}
