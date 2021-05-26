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

namespace PDT/Common {

    use SheetIO/SheetParser.SheetParser;
    
    type alias CommonData = 
        { assetName: String
        , assetType: String
        , assetStatus: String
        , manufacturer: String
        , serialNumber: String
        , specificModel: String
        , dateOfInstallation: String        /// Format needs fixing within the PDT...
        , locationOnSite: String
        , memoLine: String
        }

    type alias ProductData[t1] = 
        { common: CommonData 
        , productSpecific: t1
        }

    pub def parseProductData(inner:  SheetParser[ka1, t1]): SheetParser[ka1, ProductData[t1]] = 
        use SheetIO/SheetParser.{flatMap, return};
        let* r1 = parseCommonData();
        let* r2 = inner;
        return({common = r1, productSpecific = r2})

    pub def parseCommonData(): SheetParser[ka1, CommonData] = 
        use SheetIO/SheetParser.{flatMap, return};
        let* r1 = assetIntro();
        let* r2 = manufacturerData();
        let* r3 = assetData();
        return({assetName = r1.assetName
            , assetType = r1.assetType
            , assetStatus = r1.assetStatus
            , manufacturer = r2.manufacturer
            , serialNumber = r3.serialNumber
            , specificModel = r3.specificModel
            , dateOfInstallation = r3.dateOfInstallation
            , locationOnSite = r3.locationOnSite
            , memoLine = r3.memoLine
        })

    def assetIntro(): SheetParser[ka1, {assetName: String, assetType: String, assetStatus: String}] =
        use SheetIO/SheetParser.{flatMap, return, gotoRow, island};
        let* _  = gotoRow(0);
        let* s1 = island(rowKeyValue("Asset Type"));
        let* s2 = island(rowKeyValue("Asset Name"));
        let* s3 = island(rowKeyValue("Asset Status"));
        return({assetName = s1, assetType = s2, assetStatus = s3})

    def manufacturerData(): SheetParser[ka1, {manufacturer: String}] =
        use SheetIO/SheetParser.{flatMap, return, gotoRow, find, row, literal, island};
        let* _  = gotoRow(0);
        let* _  = find(row(literal("Manufacturer Data")));
        let* s1 = island(rowKeyValue("Manufacturer"));
        return({manufacturer = s1})


    def assetData(): SheetParser[ka1, {serialNumber: String, 
                                        specificModel: String, 
                                        dateOfInstallation: String,
                                        locationOnSite: String,
                                        memoLine: String}] =
        use SheetIO/SheetParser.{flatMap, return, gotoRow, row, find, literal, island};
        let* _  = gotoRow(0);
        let* _  = find(row(literal("Asset Data")));
        let* s1 = island(rowKeyValue("Manufacturer's serial number"));
        let* s2 = island(rowKeyValue("Date of installation"));
        let* s3 = island(rowKeyValue("Specific Model"));
        let* s4 = island(rowKeyValue("Location on Site"));
        let* s5 = island(rowKeyValue("Memo Line"));
        return({serialNumber = s1
            , dateOfInstallation = s2
            , specificModel = s3
            , locationOnSite = s4
            , memoLine = s5
        })


    pub def rowKeyValue(key: String):SheetParser[ka1, String] =
        use SheetIO/SheetParser.{row, literal, content};
        use SheetIO/SheetParser.{*>};
        row(literal(key) *> content())

}
