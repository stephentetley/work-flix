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


namespace AssetLib/GenS4/AibFacts/Attributes/LocationData {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{LocationOnSite, NationalGridRef};

    /// Read from Aib file, `Location on Site` needs to be added as an attribute

        
    /// Just reads `Location On Site`...
    pub def readLocationOnSiteData(src: XlsxSource): GenMonad[#{LocationOnSite | r}] =
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/Reader.someNamedRelations(evalLocationOnSite(), src))
        
    /// Just reads `NationalGridRef`...
    pub def readNationalGridRefData(src: XlsxSource): GenMonad[#{NationalGridRef | r}] =
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/Reader.someNamedRelations(evalNationalGridRef(), src))
        

    /// Custom attribute `Location on Site`.
    def evalLocationOnSite(): NamedRowEvaluator[#{LocationOnSite | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Location On Site",  (aibref, ans) -> #{ LocationOnSite(aibref, ans). })
        
    
    /// On all AI2 exports.
    def evalNationalGridRef(): NamedRowEvaluator[#{NationalGridRef | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Loc.Ref.",  (aibref, ans) -> #{ NationalGridRef(aibref, ans). })        


}
