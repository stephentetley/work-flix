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

    use AssetLib/S4Lite/CreateNew/Datatypes.{S4Floc => S4Funcloc, FlocAttributes, Classification};
    use AssetLib/S4Lite/CreateNew.Classifications;
    use Skeleton.S4Floc;
    use Skeleton/Datatypes.{FlocInputRow, AibInputRow};
    use Skeleton.GenMonad;


    /// type alias S4Floc = 
    ///     { functionalLocation: String
    ///     , attributes: FlocAttributes
    ///     , longText: Option[LongText]
    ///     , classifications: List[Classification]
    ///     }
    pub def genS4Floc(x: FlocInputRow): GenMonad[S4Funcloc] = 
        use Skeleton/GenMonad.{<&>, <*>};
        (x1 -> 
            { functionalLocation    = ToString.toString(x.s4Floc)
            , attributes            = x1
            , longText              = None
            , classifications       = Nil
            })
            <&> genFlocAttributes(x)
         

    /// Is adding EastNorth a rewrite rule ?

    type alias Rewrite[a] = a -> GenMonad[a]

    def updateClassifications(xs: List[Classification], ys: Classifications): List[Classification] = 
        let ys1 = AssetLib/S4Lite/CreateNew/Classifications.getClassifications(ys);
        List.append(xs, ys1)

    pub def addEastNorth(gridRef: String): Rewrite[S4Funcloc] = x -> 
        use Skeleton/GenMonad.{flatMap, return};
        let* x1 = genEastNorth(gridRef);
        return({ classifications = updateClassifications(x.classifications, x1) | x})

    pub def addAibReference(reference: String): Rewrite[S4Funcloc] = x -> 
        use Skeleton/GenMonad.{flatMap, return};
        let* x1 = genAibReference1(reference);
        return({ classifications = updateClassifications(x.classifications, x1) | x})

    pub def addSystemType(systemClass: String, description: String): Rewrite[S4Funcloc] = x -> 
        use Skeleton/GenMonad.{flatMap, return};
        let floc = Skeleton/S4Floc.new(x.functionalLocation);
        if (Skeleton/S4Floc.category(floc) != 5) 
            return(x)
        else {
            let* x1 = genLevel5System(systemClass, description);
            return({ classifications = updateClassifications(x.classifications, x1) | x})
        }

    pub def genFlocAttributes(x: FlocInputRow): GenMonad[FlocAttributes] = 
        use Skeleton/GenMonad.{flatMap, return};
        return(
            { description           = x.description
            , category              = Skeleton/S4Floc.category(x.s4Floc)
            , structureIndicator    = x.structure
            , objectType            = x.objectType
            , startupDate           = panic("startupDate")
            , maintPlant            = 2100
            , companyCode           = 2100
            , controllingArea       = 1000
            , superiorFloc          = getSuperiorFlocPath(x.s4Floc)
            , equipmentInstall      = equipmentInstall(x.structure, x.s4Floc)
            , status                = "UCON"
            })


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
        


    
    pub def genEastNorth(gridRef: String): GenMonad[Classifications] = 
        use Skeleton/GenMonad.{flatMap, return, liftOption};
        let* ngr    = liftOption(AssetLib/Common/Osgb36.parse(gridRef), "Osgb36.parse");
        let* en     = liftOption(AssetLib/Common/Osgb36.toEastingNorthing(ngr), "Osgb36.toEastingNorthing");
        let x       = AssetLib/S4Lite/CreateNew/Classifications.easting(en.easting);
        let y       = AssetLib/S4Lite/CreateNew/Classifications.northing(en.northing);
        return(Monoid.combine(x, y))

    /// For Flocs - single AI2 reference
    pub def genAibReference1(reference: String): GenMonad[Classifications] = 
        use Skeleton/GenMonad.{flatMap, return};
        let x   = AssetLib/S4Lite/CreateNew/Classifications.s4AibReference();
        let y   = AssetLib/S4Lite/CreateNew/Classifications.ai2AibReference(reference);
        return(Monoid.combine(x, y))

    /// For Equipment - two AI2 references
    pub def genAibReference2(reference: String, parent: String): GenMonad[Classifications] = 
        use Skeleton/GenMonad.{flatMap, return};
        let x   = AssetLib/S4Lite/CreateNew/Classifications.s4AibReference();
        let y   = AssetLib/S4Lite/CreateNew/Classifications.ai2AibReference(reference);
        let z   = AssetLib/S4Lite/CreateNew/Classifications.ai2AibReference(parent);
        return(Monoid.combineAll(x :: y :: z :: Nil))



    /// For Flocs (except level 5)
    pub def genUniclassCode(): GenMonad[Classifications] = 
        use Skeleton/GenMonad.{flatMap, return};
        let x   = AssetLib/S4Lite/CreateNew/Classifications.uniclassCode("UNICLASS_CODE");
        let y   = AssetLib/S4Lite/CreateNew/Classifications.uniclassDesc("UNICLASS_CODE");
        return(Monoid.combine(x, y))

    pub def genLevel5System(systemClass: String, description: String): GenMonad[Classifications] = 
        use Skeleton/GenMonad.{return};
        return(AssetLib/S4Lite/CreateNew/Classifications.stringClassification(systemClass, "SYSTEM_TYPE", description))

    pub def genEquiSystemClass(systemClass: String): GenMonad[Classifications] = 
        use Skeleton/GenMonad.{flatMap, return};
        let x   = AssetLib/S4Lite/CreateNew/Classifications.uniclassCode(systemClass);
        let y   = AssetLib/S4Lite/CreateNew/Classifications.uniclassDesc(systemClass);
        return(Monoid.combine(x, y))        

}    