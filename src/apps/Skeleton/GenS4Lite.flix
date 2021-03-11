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


namespace Skeleton/GenS4Lite {

    use BasicDb.DbMonad;

    use AssetLib/S4Lite/CreateNew/Datatypes.{S4Floc => S4Funcloc, FlocAttributes, 
        S4Equipment, EquiAttributes, Classification};
    use AssetLib/S4Lite/CreateNew.Classifications;
    use Skeleton.S4Floc;
    use Skeleton/Datatypes.{FlocInputRow, AibInputRow};
    

    pub def outputUxl( description: String
                     , flocs: List[FlocInputRow]
                     , equis: List[AibInputRow]
                     , uxlTemplate: System.FilePath
                     , outpath: System.FilePath): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, mapM};
        use BasicDb/DbMonad.{>>=};
        let* s4flocs    = mapM(genS4Floc, flocs);
        let* s4Equis    = mapM(genS4Equipment, equis) >>= relabelEquipment;
        let* _          = liftActionResult(_ -> AssetLib/S4Lite/CreateNew/EmitUxl.outputUxl(description, s4flocs, s4Equis, uxlTemplate, outpath));
        return()

    /// ## Flocs

    pub def genS4Floc(x: FlocInputRow): DbMonad[S4Funcloc] = 
        use BasicDb/DbMonad.{<&>, <*>, >>=};
        ((x1, x2) -> 
            { functionalLocation    = ToString.toString(x.s4Floc)
            , attributes            = x1
            , longText              = None
            , classifications       = x2
            })
            <&> genFlocAttributes(x)
            <*> getClassifications(genFlocClassifications(x))


    def genFlocClassifications(x: FlocInputRow): DbMonad[Classifications] = 
        use BasicDb/DbMonad.{<&>, <*>};
        use BasicDb/DbMonad.{map};
        use AssetLib/S4Lite/CreateNew/Classifications.{<<>>};
        use AssetLib/S4Lite/CreateNew/Classifications.{eastNorthWithGridRef, flocAibReference};
        ((x1, x2, x3) -> {x1 <<>> x2 <<>> x3})
            <&> map(eastNorthWithGridRef, Skeleton/DbQueries.getFlocGridRef(x.s4Floc))
            <*> map(flocAibReference, Skeleton/DbQueries.getFlocReference(x.s4Floc))
            <*> genSystemTypeOrUniclassCode(x.s4Floc, x.systemClass, x.description)
        

    def genFlocAttributes(x: FlocInputRow): DbMonad[FlocAttributes] = 
       use BasicDb/DbMonad.{<&>, <*>};
        ((x1, x2, x3) -> 
            { description           = x1
            , category              = Skeleton/S4Floc.category(x.s4Floc)
            , structureIndicator    = x.structure
            , objectType            = x2
            , startupDate           = x3
            , maintPlant            = 2100
            , companyCode           = 2100
            , controllingArea       = 1000
            , superiorFloc          = getSuperiorFlocPath(x.s4Floc)
            , equipmentInstall      = equipmentInstall(x.structure, x.s4Floc)
            , status                = "UCON"
            })
            <&> genDescriptionWithDefault(x.s4Floc, x.description)
            <*> genObjectTypeWithDefault(x.s4Floc, x.objectType)
            <*> Skeleton/DbQueries.getFlocStartupDate(x.s4Floc)

    
    def getSuperiorFlocPath(x: S4Floc): String = 
        Skeleton/S4Floc.parent(x) 
            |> Option.map(ToString.toString) 
            |> x1 -> Option.getWithDefault(x1, "")

    def equipmentInstall(structure: String, floc: S4Floc): Bool = 
        match structure { 
            case "YW-GS" => Skeleton/S4Floc.category(floc) >= 5
            case "YW-ES" => Skeleton/S4Floc.category(floc) >= 2
            case _ => false
        }

    def genDescriptionWithDefault(x: S4Floc, dflt: String): DbMonad[String] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* desc = Skeleton/DbQueries.getDescription(x);
        if (String.isEmpty(desc)) 
            return(dflt)
        else 
            return(desc)


    def genObjectTypeWithDefault(x: S4Floc, dflt: String): DbMonad[String] = 
        use BasicDb/DbMonad.{return};
        match Skeleton/S4Floc.objectType(x) {
            case Some(x1) if not String.isEmpty(x1) => return(x1)
            case _ => return(dflt)
        }

    /// ## Equipment

    /// Two traversals...
    def relabelEquipment(xs: List[S4Equipment]): DbMonad[List[S4Equipment]]  = 
        use BasicDb/DbMonad.{return, flatMap, liftAction};
        let* start = liftAction(_ -> Int32.abs(Hash.hash(Time/LocalDateTime.now())));
        let (s1, xs1) = mapAccumLeft(relabelStep1, (start, Map.empty()), xs);
        let (_, labels) = s1;
        let xs2 = List.map(relabelSuper(labels), xs1);
        return(xs2)

    /// Use two passes to relabel equipment then super-refs.
    /// First pass relabels equiId and builds a label map.
    def relabelStep1(ac: (Int32, Map[String, String]), x: S4Equipment): ((Int32, Map[String, String]), S4Equipment) = 
        let (n, labels) = ac;
        let oldId = x.equiId;
        let newId = "$${n}";
        let x1 = {equiId = newId | x};
        ((n + 1, Map.insert(oldId, newId, labels)), x1)

        

    /// Second pass relabels super-refs with a map lookup...
    def relabelSuper(labels: Map[String, String], x: S4Equipment): S4Equipment = 
        let oldSuper = x.attributes.superOrdinateEqui;
        let newSuper = Option.getWithDefault(Map.get(oldSuper, labels), "");
        {attributes = {superOrdinateEqui = newSuper | x.attributes} | x}

    /// Initially generate with AIB equiId then do a replace with fresh ids...
    pub def genS4Equipment(x: AibInputRow): DbMonad[S4Equipment] = 
        use BasicDb/DbMonad.{<&>, <*>};
        ((x1, x2) -> 
            { equiId                = x.reference
            , attributes            = x1
            , longText              = None
            , classifications       = x2
            })
            <&> genEquiAttributes(x)
            <*> getClassifications(genEquiClassifications(x))
            

    def genEquiClassifications(x: AibInputRow): DbMonad[Classifications] = 
        use BasicDb/DbMonad.{<&>, <*>};
        use BasicDb/DbMonad.{return};
        use AssetLib/S4Lite/CreateNew/Classifications.{<<>>};
        use AssetLib/S4Lite/CreateNew/Classifications.{eastNorthWithGridRef};
        ((x1, x2, x3) -> {x1 <<>> x2 <<>> x3})
            <&> return(AssetLib/S4Lite/CreateNew/Classifications.eastNorthWithGridRef(x.locRef))
            <*> genEquiAibReference(x.commonName, x.reference)
            <*> genEquiSystemClass(x.s4EquiClass)
        


    def getClassifications(x: DbMonad[Classifications]): DbMonad[List[Classification]] = 
        use BasicDb/DbMonad.{bind, liftValidation};
        bind(x, x1 -> liftValidation(AssetLib/S4Lite/CreateNew/Classifications.getClassifications(x1), String.intercalate("; ")))


    /// Category is in ztable eqobjl but it is non-deterministic.
    def genEquiAttributes(x: AibInputRow): DbMonad[EquiAttributes] = 
        use BasicDb/DbMonad.{<&>, <*>};
        (x1 ->
            { category              = x.s4Category
            , description           = x.s4Description
            , objectType            = x.s4EquiType
            , startupDate           = x.installedFrom
            , manufacturer          = x.manufacturer
            , model                 = x.model
            , partNumber            = x.specificModelFrame
            , serialNumber          = if (String.isEmpty(x.serialNumber)) "UNKNOWN" else x.serialNumber
            , constructionYear      = Time/LocalDate.getYear(x.installedFrom)
            , constructionMonth     = Time/LocalDate.getMonth(x.installedFrom)
            , maintPlant            = 2100
            , companyCode           = 2100
            , controllingArea       = 1000
            , planningPlant         = 2100
            , functionalLocation    = ToString.toString(x.s4Floc)
            , superOrdinateEqui     = x.superiorEquipment
            , techIdentNo           = ""
            , status                = x1
            })
            <&> rewriteAssetStatus(x.assetStatus)

    /// At some point this should be a db lookup...
    def rewriteAssetStatus(s: String): DbMonad[String] = 
        use BasicDb/DbMonad.{return};
        match s {
            case "OPERATIONAL" => return("OPER")
            case "NON OPERATIONAL" => return("NOP")
            case _ => return(s)
        }

    /// Classifications

    
    /// def genEastNorth(gridRef: String): DbMonad[Classifications] = 
    ///     use BasicDb/DbMonad.{flatMap, return, liftOption};
    ///     let* ngr    = liftOption(AssetLib/Common/Osgb36.parse(gridRef), "Osgb36.parse");
    ///     let* en     = liftOption(AssetLib/Common/Osgb36.toEastingNorthing(ngr), "Osgb36.toEastingNorthing");
    ///     let x       = AssetLib/S4Lite/CreateNew/Classifications.easting(en.easting);
    ///     let y       = AssetLib/S4Lite/CreateNew/Classifications.northing(en.northing);
    ///     return(Monoid.combine(x, y))

    /// For Flocs - single AI2 reference
    

    /// For Equipment - two AI2 references
    def genEquiAibReference(commonName: String, reference: String): DbMonad[Classifications] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* parent = Skeleton/DbQueries.getParentReference(commonName);
        return(AssetLib/S4Lite/CreateNew/Classifications.equiAibReference(reference, parent))


    def genSystemTypeOrUniclassCode(floc: S4Floc, systemClass: String, description: String): DbMonad[Classifications] = 
        use Skeleton/GenMonad.{flatMap, return};
        if (Skeleton/S4Floc.category(floc) != 5) 
            genUniclassCode()
        else 
            genLevel5System(systemClass, description)



    /// For Flocs (except level 5)
    def genUniclassCode(): DbMonad[Classifications] = 
        use BasicDb/DbMonad.{flatMap, return};
        let x   = AssetLib/S4Lite/CreateNew/Classifications.uniclassCode("UNICLASS_CODE");
        let y   = AssetLib/S4Lite/CreateNew/Classifications.uniclassDesc("UNICLASS_CODE");
        return(Monoid.combine(x, y))

    def genLevel5System(systemClass: String, description: String): DbMonad[Classifications] = 
        use BasicDb/DbMonad.{return};
        return(AssetLib/S4Lite/CreateNew/Classifications.stringClassification(systemClass, "SYSTEM_TYPE", description))

    def genEquiSystemClass(systemClass: String): DbMonad[Classifications] = 
        use BasicDb/DbMonad.{flatMap, return};
        let x   = AssetLib/S4Lite/CreateNew/Classifications.uniclassCode(systemClass);
        let y   = AssetLib/S4Lite/CreateNew/Classifications.uniclassDesc(systemClass);
        return(Monoid.combine(x, y))        


    pub def mapAccumLeft(f: (s, a) -> (s, b) & ef, start: s, xs: List[a]): (s, List[b]) & ef = 
        mapAccumLeftHelper(f, start, xs, (s1, ks) -> (s1, ks))

    def mapAccumLeftHelper(f: (s, a) -> (s, b) & ef, s1: s, xs: List[a], k: (s, List[b]) -> (s, List[b])): (s, List[b]) & ef = 
        match xs { 
            case Nil => k(s1, Nil)
            case x :: rs => {
                let (s2, x1) = f(s1, x);
                mapAccumLeftHelper(f, s2, rs, (s3, ks) -> k(s3, x1 :: ks))
            }

        }


}    