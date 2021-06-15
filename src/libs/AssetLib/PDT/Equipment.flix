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

namespace AssetLib/PDT/Equipment {

    use SheetIO/SheetParser.SheetParser;

    use AssetLib/S4Lite/Datatypes.{SLEquipment};

    use AssetLib/PDT/Utils.{rowKeyValue, rowKeyLocalDate};

    type alias EquipmentInfo = 
        { assetType: String
        , body: SLEquipment
        }

    pub def parseEquipmentInfo(equiId: String, category: String, objType: String): SheetParser[ka1, EquipmentInfo] = 
        use SheetIO/SheetParser.{flatMap, return};
        let* r1 = assetIntro();
        let* r2 = manufacturerData();
        let* r3 = assetData();
        let* today = AssetLib/PDT/Utils.validFromToday();
        let noPosn: Option[Int32] = None;
        let noWeight: Option[Float64] = None;
        return(
            { assetType = r1.assetType
            , body = 
                { equiId = equiId
                , category = category
                , description = r1.assetName
                , validFrom = today
                , objectType = objType
                , weightKg = noWeight                           /// ``Overall weight (dry)``
                , startupDate = r3.dateOfInstallation           /// ``Date of installation``
                , manufacturer = r2.manufacturer
                , model = r3.specificModel
                , partNumber = ""
                , serialNumber = r3.serialNumber
                , functionalLocation = r3.locationInAssetHierarchy               /// ``Location in Asset Hierarchy``
                , superOrdinateEqui = ""
                , position = noPosn
                , techIdentNo = r3.tagReference
                , status = r3.assetStatus
                }
            })



    def assetIntro(): SheetParser[ka1, {assetName: String, assetType: String, assetStatus: String}] =
        use SheetIO/SheetParser.{flatMap, return, gotoRow, island};
        let* _  = gotoRow(0);
        let* s1 = island(rowKeyValue("Asset Name"));
        let* s2 = island(rowKeyValue("Asset Type"));
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




}
