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



namespace CsoMigration/Relations {

    rel AibCso(commonName: String, sainum: String, status: String)

    rel FlocMapping(aiCommonName: String, sainum: String, siteFloc: String, s4Name: String)

    rel Level1(floc: String, description: String)
    rel Level2(site: String, floc: String, description: String)
    rel Level3(site: String, floc: String, description: String)
    rel Level4(site: String, floc: String, description: String)
    rel Level5(site: String, floc: String, description: String)


}