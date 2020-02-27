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

rel AiRepeatedAttribute(reference: String, attributeName: String, attributeValue: String)
rel AideRepeatedAttribute(reference: String, attributeName: String, attributeValue: String)
rel RepeatedAttributeDiff(reference: String, attributeName: String, aiValue: String, aideValue: String)

rel AiAttribute(reference: String, attributeName: String, attributeValue: String)
rel AideAttribute(reference: String, attributeName: String, attributeValue: String)
rel AttributeDiff(reference: String, attributeName: String, aiValue: String, aideValue: String)

rel AiAsset(reference: String, hkey: String, locationRef: String, installedDate: String)
rel AideAsset(reference: String, hkey: String, locationRef: String, installedDate: String)
rel AssetDiff(reference: String, propertyName: String, aiValue: String, aideValue: String)

rel AssetNotInAide(reference: String)
rel AssetNotInAi(reference: String)

namespace AideSync {

    pub def repeatedAttibuteDiff[r](): #{ AiRepeatedAttribute, AideRepeatedAttribute, RepeatedAttributeDiff | r } = #{
        RepeatedAttributeDiff(sai, name, ai, aide) :- 
            AiRepeatedAttribute(sai, name, ai), AideRepeatedAttribute(sai, name, aide), if ai != aide.
    }

    pub def attibuteDiff[r](): #{ AiAttribute, AideAttribute, AttributeDiff | r } = #{
        AttributeDiff(sai, name, ai, aide) :- 
            AiAttribute(sai, name, ai), AideAttribute(sai, name, aide), if ai != aide.
    }

    ///
    /// Note - there might be more properties we need to look at...
    ///
    pub def assetDiff[r](): #{ AiAsset, AideAsset, AssetDiff | r } = #{
        AssetDiff(sai, "HKey", aiHkey, aideHkey) :- 
            AiAsset(sai, aiHkey, _, _), AideAsset(sai, aideHkey, _, _), if aiHkey != aideHkey.

        AssetDiff(sai, "LocationRef", aiLocRef, aideLocRef) :- 
            AiAsset(sai, _, aiLocRef, _), AideAsset(sai, _, aideLocRef, _), if aiLocRef != aideLocRef.

        AssetDiff(sai, "InstalledFromDate", aiDate, aideDate) :- 
            AiAsset(sai, _, _, aiDate), AideAsset(sai, _, _, aideDate), if aiDate != aideDate.

    }

    pub def assetNotInAide[r](): #{ AiAsset, AideAsset, AssetNotInAide | r } = #{        
        AssetNotInAide(sai) :- AiAsset(sai, _, _, _), not AideAsset(sai, _, _, _).
    }

    pub def assetNotInAi[r](): #{ AiAsset, AideAsset, AssetNotInAide | r } = #{        
        AssetNotInAi(sai) :- AideAsset(sai, _, _, _), not AiAsset(sai, _, _, _).
    }


}
