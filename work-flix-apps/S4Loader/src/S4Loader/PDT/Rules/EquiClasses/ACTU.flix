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


namespace S4Loader/PDT/Rules/EquiClasses/ACTU {

    use S4Loader/Base/Schema.{EquiCharMapping};
    use S4Loader/PDT/Rules/EquiClasses/OneToOneMapping.{directMapping, property, makeRelations};
    
    pub def all(): #{EquiCharMapping | r} = actueh() <+> actuem()

    pub def actueh(): #{EquiCharMapping | r} = 
        directMapping("ACTUEH",                         "Hydraulic Actuator")
            |> makeRelations

    pub def actuem(): #{EquiCharMapping | r} = 
        directMapping("ACTUEM",                         "Electric Motor Actuator")
            |> property("ACTU_ATEX_CODE",                   "ATEX Code")
            |> property("IP_RATING",                        "IP Rating")
            |> property("INSULATION_CLASS_DEG_C",           "Insulation Class (°c)")
            |> property("ACTU_RATED_POWER_KW",              "Rated Power (kW)")
            |> property("ACTU_NUMBER_OF_PHASE",             "Number of Phase")
            |> property("ACTU_RATED_VOLTAGE",               "Rated Voltage")
            |> property("ACTU_RATED_VOLTAGE_UNITS",         "Rated Voltage Units")        
            |> makeRelations

 
}
