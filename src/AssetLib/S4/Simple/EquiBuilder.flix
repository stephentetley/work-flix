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


/// Build equipment from Downloadfiles + stored attrs

namespace AssetLib/S4/Simple/EquiBuilder {

    use AssetLib/S4/FileIO/DownloadFile.RowEvaluator;
    use AssetLib/S4/Simple/Datatypes.{EquiAttributes};



    /// TODO - this should be a builtin in the S4/FileTypes/DownloadFile namespace
    pub def equiRowEvaluator(): RowEvaluator[{equiId: String, attrs: EquiAttributes}] = 
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{getStringNamed, getS4DateNamed, getInt32Named};
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18) ->
                { equiId                = x1
                , attrs = 
                    { category              = x2
                    , description           = x3
                    , objectType            = x4
                    , startupDate           = x5
                    , manufacturer          = x6
                    , model                 = x7
                    , partNumber            = x8
                    , serialNumber          = x9
                    , constructionYear      = x10
                    , constructionMonth     = x11
                    , maintPlant            = x12
                    , companyCode           = x13
                    , costCenter            = x14
                    , planningPlant         = x15
                    , functionalLocation    = x16
                    , superOridinateEqui    = x17
                    , status                = x18
                    }
                })
            <&> getStringNamed("EQUI")                  /// Equipment ID
            <*> getStringNamed("EQTYP")                 /// Equipment Category
            <*> getStringNamed("TXTMI")                 /// Description (medium text)        
            <*> getStringNamed("EQART_EQU")             /// Object Type          
            <*> getS4DateNamed("INBDT")                 /// Startup Date
            <*> getStringNamed("HERST")                 /// Manufacturer
            <*> getStringNamed("TYPBZ")                 /// Model 
            <*> getStringNamed("MAPA_EEQZ")             /// Manufact Part No
            <*> getStringNamed("SERGE")                 /// Manufact Serial Number
            <*> getInt32Named("BAUJJ")                  /// Construction year
            <*> getInt32Named("BAUMM_EQI")              /// Construction month
            <*> getInt32Named("SWER_EILO")              /// Maintenance Plant
            <*> getInt32Named("BUKR_EILO")              /// Company Code
            <*> getInt32Named("KOST_EILO")              /// Cost Center
            <*> getInt32Named("PPLA_EEQZ")              /// Planning Plant
            <*> getStringNamed("TPLN_EILO")             /// Functional Location
            <*> getStringNamed("HEQU_EEQZ")             /// Superord Equipment
            <*> getStringNamed("USTW_EQUI")             /// Status of an object

}