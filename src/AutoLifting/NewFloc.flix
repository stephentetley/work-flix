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

namespace AutoLifting/NewFloc {
    
    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/S4/Base.Floc;
    use AssetLib/S4/Simple.Classifications;
    use AssetLib/S4/Simple/Datatypes.{S4Floc, Classification};
    use AssetLib/S4/Simple/Datatypes.ValueType.{Text};

    type alias LiftingFloc = 
        { functionalLocation: Floc
        , description: String
        , objectType: String
        , startupDate: Time.LocalDate
        , equipmentInstall: Bool
        , classifications: Classifications             /// UNICLASS_CODE or SLFSSY
        }

    pub def makeS4Floc(x: LiftingFloc): S4Floc = 
        use AssetLib/S4/Simple/Classifications.{getClassifications};
        use AssetLib/S4/Base/Floc.{toString, pop, level};
        { functionalLocation    = toString(x.functionalLocation)
        , attributes = 
            { description           = x.description
            , category              = level(x.functionalLocation)
            , structureIndicator    = "YW-GS"
            , objectType            = x.objectType
            , startupDate           = x.startupDate
            , maintPlant            = 2100
            , companyCode           = 2100
            , controllingArea       = 1000
            , superiorFloc          = toString(pop(x.functionalLocation))
            , equipmentInstall      = x.equipmentInstall
            , status                = "UCON"
            }
        , longText              = None
        , classifications       = getClassifications(x.classifications)
        }



    pub def siteMaintenanceServices( siteRoot: String
                                   , startupDate: Time.LocalDate
                                   , easting: Int32
                                   , northing: Int32
                                   , reference: String): LiftingFloc = 
        use AssetLib/S4/Simple/Classifications.{append}; 
        { functionalLocation    = AssetLib/S4/Base/Floc.new("${siteRoot}-SMS")
        , description           = "Site Maintenance Services"
        , objectType            = "SMS"
        , startupDate           = startupDate
        , equipmentInstall      = false
        , classifications       = aibReference(reference) `append` eastingNorthing(easting, northing) `append` uniclassCode()
        }

    pub def siteLifting( siteRoot: String
                       , startupDate: Time.LocalDate
                       , easting: Int32
                       , northing: Int32
                       , reference: String): LiftingFloc = 
        use AssetLib/S4/Simple/Classifications.{append}; 
        { functionalLocation    = AssetLib/S4/Base/Floc.new("${siteRoot}-SMS-LFT")
        , description           = "Site Lifting"
        , objectType            = "LFT"
        , startupDate           = startupDate
        , equipmentInstall      = false
        , classifications       = aibReference(reference) `append` eastingNorthing(easting, northing) `append` uniclassCode()
        }

    pub def fixedLifting( siteRoot: String
                        , startupDate: Time.LocalDate
                        , easting: Int32
                        , northing: Int32
                        , reference: String): LiftingFloc = 
        use AssetLib/S4/Simple/Classifications.{append}; 
        { functionalLocation    = AssetLib/S4/Base/Floc.new("${siteRoot}-SMS-LFT-FLT")
        , description           = "Fixed Lifting"
        , objectType            = "LFT"
        , startupDate           = startupDate
        , equipmentInstall      = false
        , classifications       = aibReference(reference) `append` eastingNorthing(easting, northing) `append` uniclassCode()
        }

    pub def fixedLiftingSystem( siteRoot: String
                              , startupDate: Time.LocalDate
                              , easting: Int32
                              , northing: Int32
                              , reference: String): LiftingFloc = 
        use AssetLib/S4/Simple/Classifications.{append}; 
        { functionalLocation    = AssetLib/S4/Base/Floc.new("${siteRoot}-SMS-LFT-FLT-SYS01")
        , description           = "Fixed Lifting System"
        , objectType            = "SLFS"
        , startupDate           = startupDate
        , equipmentInstall      = false
        , classifications       = aibReference(reference) `append` eastingNorthing(easting, northing) `append` slfssy("Fixed Lifting System")
        }

    pub def portableLifting( siteRoot: String
                           , startupDate: Time.LocalDate
                           , easting: Int32
                           , northing: Int32
                           , reference: String): LiftingFloc = 
        use AssetLib/S4/Simple/Classifications.{append}; 
        { functionalLocation    = AssetLib/S4/Base/Floc.new("${siteRoot}-SMS-LFT-PRL")
        , description           = "Portable Lifting"
        , objectType            = "LFT"
        , startupDate           = startupDate
        , equipmentInstall      = false
        , classifications       = aibReference(reference) `append` eastingNorthing(easting, northing) `append` uniclassCode()
        }

    pub def portableLiftingSystem( siteRoot: String
                                 , startupDate: Time.LocalDate
                                 , easting: Int32
                                 , northing: Int32
                                 , reference: String): LiftingFloc = 
        use AssetLib/S4/Simple/Classifications.{append}; 
        { functionalLocation    = AssetLib/S4/Base/Floc.new("${siteRoot}-SMS-LFT-PRL-SYS01")
        , description           = "Portable Lifting System"
        , objectType            = "SLFS"
        , startupDate           = startupDate
        , equipmentInstall      = false
        , classifications       = aibReference(reference) `append` eastingNorthing(easting, northing) `append` slfssy("Portable Lifting System")
        }

    def aibReference(reference: String): Classifications = 
        use AssetLib/S4/Simple/Classifications.{append, ai2AibReference, s4AibReference};
        ai2AibReference(reference) `append` s4AibReference()

    def eastingNorthing(e: Int32, n: Int32): Classifications = 
        use AssetLib/S4/Simple/Classifications.{append, easting, northing};
        easting(e) `append` northing(n)

    def uniclassCode(): Classifications = 
        use AssetLib/S4/Simple/Classifications.{append, uniclassCode, uniclassDesc};
        uniclassCode("UNICLASS_CODE") `append` uniclassDesc("UNICLASS_CODE")


    def slfssy(systemName: String): Classifications =
        use AssetLib/S4/Simple/Classifications.{singleton};
        singleton({className = "SLFSSY", charName = "System Type", datatype = Text, value = systemName})

}