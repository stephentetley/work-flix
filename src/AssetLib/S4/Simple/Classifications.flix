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

namespace AssetLib/S4/Simple {
    
    use Data/Transitional.DList;
    use AssetLib/S4/Simple/Datatypes.{Classification};

    pub opaque type Classifications = Data/Transient.DList[Classification]
}

namespace AssetLib/S4/Simple/Classifications {

    use AssetLib/S4/Simple.Classifications;
    use AssetLib/S4/Simple.Classifications.{Classifications};
    use AssetLib/S4/Simple/Datatypes.{Classification};

    pub def getClassifications(x: Classifications): List[Classification] = 
        let Classifications(x1) = x;
        Data/Transient/DList.toList(x1)

    pub def empty(): Classifications =         
        Classifications(Data/Transient/DList.empty())

    pub def singleton(x: Classification): Classifications =         
        Classifications(Data/Transient/DList.singleton(x))

    pub def append(x: Classifications, y: Classifications): Classifications = 
        let Classifications(x1) = x;
        let Classifications(y1) = y;        
        Classifications(Data/Transient/DList.append(x1, y1))

    pub def concat(xs: List[Classifications]): Classifications = 
        List.foldLeft((x,y) -> append(x,y), empty(), xs)
        

    /// 
    pub def whenTrue(test: Bool, x: Classifications): Classifications = 
        if (test) x else empty()

    pub def whenSome(x: Option[x], build: x -> Classifications): Classifications = match x { 
        case Some(x1) => build(x1)
        case None => empty()
    }

    pub def easting(i: Int32): Classifications = 
        singleton({className = "EAST_NORTH", charName = "EASTING", datatype = "Int", value = Int32.toString(i)})

    pub def northing(i: Int32): Classifications = 
        singleton({className = "EAST_NORTH", charName = "NORTHING", datatype = "Int", value = Int32.toString(i)})

    pub def s4AibReference(): Classifications =
        singleton({className = "AIB_REFERENCE", charName = "S4_AIB_REFERENCE", datatype = "Text", value = ""})

    pub def ai2AibReference(reference: String): Classifications =
        singleton({className = "AIB_REFERENCE", charName = "AI2_AIB_REFERENCE", datatype = "Text", value = reference})

    pub def uniclassCode(classification: String): Classifications =
        singleton({className = classification, charName = "UNICLASS_CODE", datatype = "Text", value = ""})

    pub def uniclassDesc(classification: String): Classifications =
        singleton({className = classification, charName = "UNICLASS_DESC", datatype = "Text", value = ""})

    pub def locationOnSite(classification: String, location: String): Classifications =
        singleton({className = classification, charName = "LOCATION_ON_SITE", datatype = "Text", value = location})

    pub def statutoryReferenceNumber(classification: String, reference: String): Classifications =
        singleton({className = classification, charName = "STATUTORY_REFERENCE_NUMBER", datatype = "Text", value = reference})

    pub def testCertNo(classification: String, reference: String): Classifications =
        singleton({className = classification, charName = "TEST_CERT_NO", datatype = "Text", value = reference})
}