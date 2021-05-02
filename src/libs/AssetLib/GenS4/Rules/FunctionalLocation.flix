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

namespace AssetLib/Gens4/FlocGen/Rules {


    use AssetLib/GenS4/UxlRelations.{FlocDatum, FlocCharacteristic};
    use AssetLib/GenS4/WorkListRelations.{FlocWorkItem};




    pub def genFloc(installedFrom: Time.LocalDate): #{FlocWorkItem, FlocDatum, FlocCharacteristic | r} = 
        #{
            FlocDatum(funcloc, 
                        description,
                        "YW-GS",
                        objectType,
                        installedFrom,
                        level >= 5,
                        "UCON") :- 
                FlocWorkItem(funcloc, description, level, objectType, _, _,  _).


            FlocCharacteristic(funcloc, "UNICLASS_CODE", "UNICLASS_CODE", "") :- 
                FlocWorkItem(funcloc, _, level,  _, _, _,  _),
                if level != 5.

            FlocCharacteristic(funcloc, "UNICLASS_CODE", "UNICLASS_DESC", "") :- 
                FlocWorkItem(funcloc, _, level,  _, _, _, _),
                if level != 5.

            FlocCharacteristic(funcloc, systemClass, systemType, "") :- 
                FlocWorkItem(funcloc, _, level,  _, systemClass, systemType, _),
                if level == 5.
        }



}

