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

    use AssetLib/S4Lite/Datatypes.{SLEquipment};
    
    type alias CommonData = 
        { assetName: String
        , assetType: String
        , assetStatus: String
        , manufacturer: String
        , serialNumber: String
        , specificModel: String
        , dateOfInstallation: Time.LocalDate        /// Format needs fixing within the PDT...
        , locationInAssetHierarchy: String
        , locationOnSite: String
        , memoLine: String
        }

    /// TODO - needs name supply. Name supply could be provided in the parser
    /// by lifting name gen based on LocalDateTime then we would have ids that can
    /// be ordered.
    /// pub def toSLEquipment(x: CommonData): SLEquipment =
    ///     { equiId: String
    ///     , category: String              /// dependent on input type 
    ///     , description: String
    ///     , validFrom: Time.LocalDate
    ///     , objectType: String
    ///     , weightKg: Option[Float64]
    ///     , startupDate: Time.LocalDate
    ///     , manufacturer = x.
    ///     , model: String
    ///     , partNumber: String
    ///     , serialNumber: String
    ///     , functionalLocation: String
    ///     , superOrdinateEqui: String
    ///     , position: Option[Int32]
    ///     , techIdentNo: String
    ///     , status: String
    ///     }


    type alias ProductData[t1] = 
        { common: CommonData 
        , productSpecific: t1
        }

    pub def parseProductData(inner:  SheetParser[ka1, t1]): SheetParser[ka1, ProductData[t1]] = 
        use SheetIO/SheetParser.{flatMap, return};
        let* r1 = parseCommonData();
        let* r2 = inner;
        return({common = r1, productSpecific = r2})



    pub def parseEquipment(equiId: String, category: String, today: Time.LocalDate, objType: String): SheetParser[ka1, SLEquipment] = 
        use SheetIO/SheetParser.{flatMap, return};
        let* r1 = assetIntro();
        let* r2 = manufacturerData();
        let* r3 = assetData();
        let noPosn: Option[Int32] = None;
        let noWeight: Option[Float64] = None;
        return({ equiId = equiId
            , category = category
            , description = r1.assetName
            , validFrom = today
            , objectType = objType
            , weightKg = noWeight                           /// ``Overall weight (dry)``
            , startupDate = r3.dateOfInstallation       /// ``Date of installation``
            , manufacturer = r2.manufacturer
            , model = r3.specificModel
            , partNumber = ""
            , serialNumber = r3.serialNumber
            , functionalLocation = r3.locationInAssetHierarchy               /// ``Location in Asset Hierarchy``
            , superOrdinateEqui = ""
            , position = noPosn
            , techIdentNo = r3.tagReference
            , status = r3.assetStatus
            })



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
            , locationInAssetHierarchy = r3.locationInAssetHierarchy
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

    type alias AssetData1 = 
        { serialNumber: String
        , dateOfInstallation: Time.LocalDate
        , tagReference: String
        , locationInAssetHierarchy: String
        , specificModel: String
        , locationOnSite: String
        , memoLine: String
        , assetStatus: String
        }

    def assetData(): SheetParser[ka1, AssetData1] =
        use SheetIO/SheetParser.{flatMap, return, gotoRow, row, find, literal, island};
        let* _  = gotoRow(0);
        let* _  = find(row(literal("Asset Data")));
        let* s1 = island(rowKeyValue("Manufacturer's serial number"));
        let* s2 = island(rowKeyLocalDate("Date of installation"));
        let* s3 = island(rowKeyValue("Tag reference"));
        let* s4 = island(rowKeyValue("Location in Asset Hierarchy"));
        let* s5 = island(rowKeyValue("Specific Model"));
        let* s6 = island(rowKeyValue("Location on Site"));
        let* s7 = island(rowKeyValue("Memo Line"));
        let* s8 = island(rowKeyValue("Asset Status"));
        return({serialNumber = s1
                , dateOfInstallation = s2
                , tagReference = s3
                , locationInAssetHierarchy = s4 
                , specificModel = s5           
                , locationOnSite = s6
                , memoLine = s7
                , assetStatus = s8
                })


    pub def rowKeyValue(key: String): SheetParser[ka1, String] =
        use SheetIO/SheetParser.{row, literal, content};
        use SheetIO/SheetParser.{*>};
        row(literal(key) *> content())

    pub def rowKeyLocalDate(key: String): SheetParser[ka1, Time.LocalDate] =
        use SheetIO/SheetParser.{row, literal, localDate};
        use SheetIO/SheetParser.{*>};
        row(literal(key) *> localDate())


    /// pub def genName(): SheetParser[ka1, String] = 
    ///     use SheetIO/SheetParser.{liftAction};
    ///     liftAction(_ -> )

    /// /// 9-digit
    /// def start(): Int32 & Impure = 
    ///     let dt = Time/LocalDateTime.now();
    ///     let x2  = Time/LocalDateTime.getDayOfMonth(dt) * 1000000;
    ///     let x3  = Time/LocalDateTime.getHour(dt) * 10000;
    ///     let x4  = Time/LocalDateTime.getMinute(dt) * 100;
    ///     let x4  = Time/LocalDateTime.getSecond(dt) * 100;
    ///     200000000 + x1 + x2 + x3 + x4


}
