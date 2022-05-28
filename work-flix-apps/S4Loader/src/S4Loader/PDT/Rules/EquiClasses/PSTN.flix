/*
 * Copyright 2022 Stephen Tetley
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


namespace S4Loader/PDT/Rules/EquiClasses/PSTN {

    use S4Loader/Base/Schema.{EquiCharMapping};
    use S4Loader/PDT/Rules/EquiClasses/OneToOneMapping.{directMapping, property, makeRelations};
    
    pub def all(): #{EquiCharMapping | r} = pstndi()

    pub def pstndi(): #{EquiCharMapping | r} = 
        directMapping("PSTNDI",                         "Diaphragm Type Pressure Device")
            |> property("IP_RATING",                        "IP Rating")
            |> property("PSTN_SIGNAL_TYPE",                 "Output Signal Type")	
            |> property("PSTN_RANGE_MAX",                   "Range Max")
            |> property("PSTN_RANGE_MIN",                   "Range Min")
            |> property("PSTN_RANGE_UNITS",                 "Range Unit")
            |> property("PSTN_SUPPLY_VOLTAGE",              "Supply Voltage")
            |> property("PSTN_SUPPLY_VOLTAGE_UNITS",        "Supply Voltage Units")
            |> makeRelations

}
