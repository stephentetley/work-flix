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


namespace AssetLib/AibFacts/Attributes/Electrical {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/AibFacts/Relations.{AibStringValue, AibIntValue, AibFloatValue};
    use AssetLib/AibFacts/Relations.{getAttributes, getStringValue, getIntValue, getFloatValue};



    /// Read from Aib file...


    pub def readElectricalData(sheetName: String, 
                                path: System.FilePath): Result[#{AibStringValue, AibIntValue, AibFloatValue | r}, String] & Impure =
        AssetLib/AibFacts/Relations.readAibFacts(aibElectrical(), sheetName, path)
        


    pub def aibElectrical(): NamedRowEvaluator[#{AibStringValue, AibIntValue, AibFloatValue | r}] =
        getAttributes( getCurrentIn()
            :: getInsulationClass()
            :: getIPRating()
            :: getPower()
            :: getPowerUnits()
            :: getSpeedRPM()
            :: getVoltageIn()
            :: getVoltageInACOrDC()
            :: Nil
        )      



    pub def getCurrentIn(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Current In", "CURRENT_IN")

    pub def getInsulationClass(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Insulation Class", "INSULATION_CLASS")

    /// Probably always an integer in our data...
    pub def getIPRating(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("IP Rating", "IP_RATING")

    pub def getPower(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Power", "POWER")

    pub def getPowerUnits(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Power Units", "POWER_UNITS")

    pub def getSpeedRPM(): NamedRowEvaluator[#{AibIntValue | r}] =
        getIntValue("Speed (RPM)", "SPEED_RPM")

    pub def getVoltageIn(): NamedRowEvaluator[#{AibIntValue | r}] =
        getIntValue("Voltage In", "VOLTAGE_IN")

    pub def getVoltageInACOrDC(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Voltage In (AC Or DC)", "VOLTAGE_IN_AC_OR_DC")

}
