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


namespace AssetLib/AibFacts/Attributes/LocationData {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/AibFacts/Utils.{getStringValuedFact};


    pub rel LocationOnSite(aibref: String, text: String)
    pub rel Osgb36GridRef(aibref: String, gridRef: String)

    /// Read from Aib file, `Location on Site` needs to be added as an attribute

        
    /// Just reads `Location On Site`...
    pub def readLocationOnSiteData(src: XlsxSource): Result[#{LocationOnSite | r}, String] & Impure =
        AssetLib/AibFacts/Utils.readAibFacts(getLocationOnSite(), true, src)

    /// Just reads `Osgb36GridRef`...
    pub def readOsgb36GridRefData(src: XlsxSource): Result[#{Osgb36GridRef | r}, String] & Impure =
        AssetLib/AibFacts/Utils.readAibFacts(getOsgb36GridRef(), true, src)


    /// Custom attribute `Location on Site`.
    pub def getLocationOnSite(): NamedRowEvaluator[#{LocationOnSite | r}] =
        getStringValuedFact("Location On Site",  (aibref, ans) -> #{ LocationOnSite(aibref, ans). })
        
    
    /// On all AI2 exports.
    pub def getOsgb36GridRef(): NamedRowEvaluator[#{Osgb36GridRef | r}] =
        getStringValuedFact("Loc.Ref.",  (aibref, ans) -> #{ Osgb36GridRef(aibref, ans). })        


}
