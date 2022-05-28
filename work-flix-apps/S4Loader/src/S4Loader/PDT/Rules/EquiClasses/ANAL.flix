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


namespace S4Loader/PDT/Rules/EquiClasses/ANAL {

    use S4Loader/Base/Schema.{EquiCharMapping};
    use S4Loader/PDT/Rules/EquiClasses/OneToOneMapping.{OneToOneMappingBuilder, directMapping, property, makeRelations};
    
    pub def all(): #{EquiCharMapping | r} = analal()

    def commonProperties(): OneToOneMappingBuilder =
        property("ANAL_SIGNAL_TYPE",                 "Output Signal Type")
            >> property("ANAL_RANGE_MAX",                   "Range Max")
            >> property("ANAL_RANGE_MIN",                   "Range Min")
            >> property("ANAL_RANGE_UNITS",                 "Range Unit")


    /// Aluminium (Ion) Analyser
    pub def analal(): #{EquiCharMapping | r} = 
        directMapping("ANALAL",                         "Aluminium (Ion) Analyser")
            |> commonProperties()
            |> property("ANAL_INSTRUMENT_POWER_W",          "Instrument Power (W)")
            |> property("IP_RATING",                        "IP Rating")

            |> makeRelations


}
