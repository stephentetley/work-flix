/*
 * Copyright 2020 Stephen Tetley
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

namespace AssetLib/S4Lite/CreateNew {
    
    /// use Data/Transitional.DList;
    use AssetLib/S4Lite/CreateNew/Datatypes.{Classification};

    pub opaque type Classifications = Validation[Chain[Classification], String]

    instance Monoid[Classifications] {
        def empty(): Classifications = AssetLib/S4Lite/CreateNew/Classifications.empty()

        def combine(xs: Classifications, ys: Classifications): Classifications = 
            AssetLib/S4Lite/CreateNew/Classifications.append(xs, ys)
    }

}

namespace AssetLib/S4Lite/CreateNew/Classifications {

    use AssetLib/S4Lite/CreateNew.Classifications;
    use AssetLib/S4Lite/CreateNew.Classifications.{Classifications};
    use AssetLib/S4Lite/CreateNew/Datatypes.{Classification};
    use AssetLib/S4Lite/CreateNew/Datatypes.Value.{Text, Integer, Decimal};

    pub def getClassifications(x: Classifications): Validation[List[Classification], String] = 
        let Classifications(x1) = x;
        Validation.map(Chain.toList, x1)

    pub def empty(): Classifications =         
        Classifications(Success(Chain.empty()))

    pub def singleton(x: Classification): Classifications =         
        Classifications(Success(Chain.singleton(x)))


    pub def throwError(errMsg: String): Classifications =
        Classifications(Failure(Nel.singleton(errMsg)))

    pub def append(x: Classifications, y: Classifications): Classifications = 
        let Classifications(x1) = x;
        let Classifications(y1) = y;
        match (x1, y1) {
            case (Success(c1), Success(c2)) => Classifications(Success(Chain.append(c1, c2)))
            case (Failure(es1), Success(_)) => Classifications(Failure(es1))
            case (Success(_), Failure(es2)) => Classifications(Failure(es2))
            case (Failure(es1), Failure(es2)) => Classifications(Failure(Nel.append(es1, es2)))
        }

    pub def <<>>(x: Classifications, y: Classifications): Classifications = append(x, y)

    pub def concat(xs: List[Classifications]): Classifications = 
        List.foldLeft((x,y) -> append(x,y), empty(), xs)
        

    /// 
    pub def whenTrue(test: Bool, x: Classifications): Classifications = 
        if (test) x else empty()

    pub def whenSome(x: Option[x], build: x -> Classifications): Classifications = match x { 
        case Some(x1) => build(x1)
        case None => empty()
    }

    pub def stringClassification(className: String, charName: String, value: String): Classifications = 
        singleton({className = className, charName = charName, value = Text(value)})

    pub def intClassification(className: String, charName: String, value: Int32): Classifications = 
        singleton({className = className, charName = charName, value = Integer(value)})

    pub def decimalClassification(className: String, charName: String, value: Float64): Classifications = 
        singleton({className = className, charName = charName, value = Decimal(value)})

    pub def easting(i: Int32): Classifications = intClassification("EAST_NORTH", "EASTING", i)

    pub def northing(i: Int32): Classifications = intClassification("EAST_NORTH", "NORTHING", i)


    pub def eastNorthWithGridRef(gridRef: String): Classifications = 
        use Option.flatMap;
        let step = () -> {
            let* ngr    = AssetLib/Common/Osgb36.parse(gridRef);
            let* en     = AssetLib/Common/Osgb36.toEastingNorthing(ngr);
            Some(en)
        };
        match step() { 
            case None => throwError("eastNorthWithGridRef('${gridRef}')")
            case Some(en) => append(easting(en.easting), northing(en.northing))
        }


    pub def s4AibReference(): Classifications = stringClassification("AIB_REFERENCE", "S4_AIB_REFERENCE", "")

    pub def ai2AibReference(reference: String): Classifications =
        singleton({className = "AIB_REFERENCE", charName = "AI2_AIB_REFERENCE", value = Text(reference)})


    pub def flocAibReference(reference: String): Classifications = 
        ai2AibReference(reference) <<>> s4AibReference()

    pub def equiAibReference(reference: String, parent: String): Classifications = 
        ai2AibReference(reference) <<>> ai2AibReference(parent) <<>> s4AibReference()


    pub def uniclassCode(className: String): Classifications =
        singleton({className = className, charName = "UNICLASS_CODE", value = Text("")})

    pub def uniclassDesc(className: String): Classifications =
        singleton({className = className, charName = "UNICLASS_DESC", value = Text("")})

    pub def flocUniclassCode(): Classifications = 
        uniclassCode("UNICLASS_CODE") <<>> uniclassDesc("UNICLASS_CODE")

    pub def flocLevel5SystemType(className: String, systemName: String): Classifications = 
        singleton({className = className, charName = "SYSTEM_TYPE", value = Text(systemName)})


    pub def locationOnSite(classification: String, location: String): Classifications =
        singleton({className = classification, charName = "LOCATION_ON_SITE", value = Text(location)})

    pub def statutoryReferenceNumber(classification: String, reference: String): Classifications =
        singleton({className = classification, charName = "STATUTORY_REFERENCE_NUMBER", value = Text(reference)})

    pub def testCertNo(classification: String, reference: String): Classifications =
        singleton({className = classification, charName = "TEST_CERT_NO", value = Text(reference)})

}