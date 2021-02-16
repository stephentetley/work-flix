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

    use AssetLib/S4Lite/CreateNew/Datatypes.{S4Floc => S4Funcloc, FlocAttributes, Classification};
    use AssetLib/S4Lite/CreateNew.Classifications;
    use Skeleton.S4Floc;
    use Skeleton/Datatypes.{FlocInputRow, AibInputRow};
    

    pub def outputUxl( description: String
                     , flocs: List[FlocInputRow]
                    ///  , equis: List[S4Equipment]
                     , uxlTemplate: System.FilePath
                     , outpath: System.FilePath): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, mapM};
        let* s4flocs    = mapM(genS4Floc, flocs);
        let* _          = liftActionResult(_ -> AssetLib/S4Lite/CreateNew/EmitUxl.outputUxl(description, s4flocs, Nil, uxlTemplate, outpath));
        return()


    pub def genS4Floc(x: FlocInputRow): DbMonad[S4Funcloc] = 
        use BasicDb/DbMonad.{<&>, <*>, >>=};
        ((x1, c1, c2, c3) -> 
            { functionalLocation    = ToString.toString(x.s4Floc)
            , attributes            = x1
            , longText              = None
            , classifications       = 
                AssetLib/S4Lite/CreateNew/Classifications.getClassifications(Monoid.combineAll(c1 :: c2 :: c3 :: Nil))
            })
            <&> genFlocAttributes(x)
            <*> (Skeleton/DbQueries.getFlocGridRef(x.s4Floc) >>= genEastNorth)
            <*> (Skeleton/DbQueries.getFlocReference(x.s4Floc) >>= genAibReference1)
            <*> genSystemTypeOrUniclassCode(x.s4Floc, x.systemClass, x.description)


    def genFlocAttributes(x: FlocInputRow): DbMonad[FlocAttributes] = 
       use BasicDb/DbMonad.{alt};
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

    /// Helper for writing functions where user might have supplied optional data...
    pub def nonBlank(s: String): DbMonad[String] = 
        if (String.isEmpty(s))
            BasicDb/DbMonad.throwError("nonBlank - blank")
        else 
            BasicDb/DbMonad.return("nonBlank - blank")


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

    /// /// Category is in ztable eqobjl but it is non-deterministic.
    /// pub def genEquiAttributes(category: String): GenMonad[EquiAttributes] = 
    ///     use Skeleton/GenMonad.{flatMap, return};
    ///     return(
    ///         { category              = category
    ///         , description           = "**name**"
    ///         , objectType: String
    ///         , startupDate: Time.LocalDate
    ///         , manufacturer: String
    ///         , model: String
    ///         , partNumber: String
    ///         , serialNumber: String
    ///         , constructionYear: Int32
    ///         , constructionMonth: Int32
    ///         , maintPlant: Int32
    ///         , companyCode: Int32
    ///         , controllingArea: Int32
    ///         , planningPlant: Int32
    ///         , functionalLocation: String
    ///         , superOrdinateEqui: String
    ///         , techIdentNo: String
    ///         , status: String
    ///         })
        


    
    pub def genEastNorth(gridRef: String): DbMonad[Classifications] = 
        use BasicDb/DbMonad.{flatMap, return, liftOption};
        let* ngr    = liftOption(AssetLib/Common/Osgb36.parse(gridRef), "Osgb36.parse");
        let* en     = liftOption(AssetLib/Common/Osgb36.toEastingNorthing(ngr), "Osgb36.toEastingNorthing");
        let x       = AssetLib/S4Lite/CreateNew/Classifications.easting(en.easting);
        let y       = AssetLib/S4Lite/CreateNew/Classifications.northing(en.northing);
        return(Monoid.combine(x, y))

    /// For Flocs - single AI2 reference
    pub def genAibReference1(reference: String): DbMonad[Classifications] = 
        use BasicDb/DbMonad.{flatMap, return};
        let x   = AssetLib/S4Lite/CreateNew/Classifications.s4AibReference();
        let y   = AssetLib/S4Lite/CreateNew/Classifications.ai2AibReference(reference);
        return(Monoid.combine(x, y))

    /// For Equipment - two AI2 references
    pub def genAibReference2(x: AibInputRow): DbMonad[Classifications] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* parent = Skeleton/DbQueries.getParentReference(x.commonName);
        let c1  = AssetLib/S4Lite/CreateNew/Classifications.s4AibReference();
        let c2  = AssetLib/S4Lite/CreateNew/Classifications.ai2AibReference(x.reference);
        let c3  = AssetLib/S4Lite/CreateNew/Classifications.ai2AibReference(parent);
        return(Monoid.combineAll(c1 :: c2 :: c3 :: Nil))


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

    pub def genEquiSystemClass(systemClass: String): DbMonad[Classifications] = 
        use BasicDb/DbMonad.{flatMap, return};
        let x   = AssetLib/S4Lite/CreateNew/Classifications.uniclassCode(systemClass);
        let y   = AssetLib/S4Lite/CreateNew/Classifications.uniclassDesc(systemClass);
        return(Monoid.combine(x, y))        

}    