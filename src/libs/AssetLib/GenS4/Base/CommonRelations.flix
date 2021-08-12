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


namespace AssetLib/GenS4/Base/CommonRelations {

    /// `itemId` will be pli-number for facts extracted from Aib Exports.
    /// But it can represent other item types depending where the facts come from.

    pub rel EquiWorkItem3(itemId: String, s4ObjType: String, s4Class: String)

    
    /// Floc equivalent to `EquiWorkItem3` is local to the `FunctionalLocation` module



    pub rel AibMemoLine(aibref: String, text: String)

    
    pub rel AibParentRef(aibref: String, commonName: String, parent: String)


    /// Asset Condition

    pub rel ConditionGrade(itemId: String, grade: String, reason: String)

    pub rel LoadingFactor(itemId: String, factor: String, reason: String)

    pub rel PerformanceGrade(itemId: String, grade: String, reason: String)

    pub rel SurveyYear(itemId: String, year: Int32)

    /// Electrical
    
    pub rel CurrentInA(itemId: String, current: Float64)

    pub rel InsulationClass(itemId: String, insclass: String)

    pub rel IPRating(itemId: String, iprating: String)

    /// AIB: `Power` and `Power Units`
    pub rel Power(itemId: String, power: Float64, units: String)

    pub rel SpeedRPM(itemId: String, speed: Int32)

    pub rel VoltageIn(itemId: String, voltage: Int32, voltageACOrDC: String)

    /// Instrument

    pub rel RangeMinMax(itemId: String, rmin: Float64, rmax: Float64, units: String)

    pub rel SignalMinMax(itemId: String, smin: Float64, smax: Float64, units: String)

    pub rel Transducer(itemId: String, model: String, serialNumber: String)

    /// Lifting

    pub rel WorkLoad(aibref: String, load: Float64, units: String)

    pub rel TestCertNo(aibref: String, number: String)
    
    pub rel YWRef(aibref: String, refnum: String)

    /// Location Data 
    
    pub rel LocationOnSite(aibref: String, text: String)
    
    pub rel NationalGridRef(aibref: String, gridRef: String)


    /// Pump / Pums

    pub rel PumpDiaphragmMaterial(itemId: String, material: String)

    pub rel PumpDutyHead(itemId: String, size: Float64, units: String)
    
    pub rel PumpFlow(itemId: String, flow: Float64, units: String)

    pub rel PumpImpellerType(itemId: String, impellerType: String)

    /// AIB: `Lifting Type`
    pub rel PumpLiftingType(itemId: String, liftingType: String)


    /// AIB: `Rating (Power)` and `Rating Units`
    pub rel PumpRatingPower(itemId: String, rating: Float64, units: String)
}
