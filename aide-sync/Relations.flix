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

rel AiRepeatedAttribute(reference: String, pageName: String, attributeName: String, attributeValue: String)
rel AideRepeatedAttribute(reference: String, pageName: String, attributeName: String, attributeValue: String)
rel RepeatedAttributeDiff(reference: String, pageName: String, attributeName: String, aiValue: String, aideValue: String)

rel AiAttribute(reference: String, attributeName: String, attributeValue: String)
rel AideAttribute(reference: String, attributeName: String, attributeValue: String)
rel AttributeDiff(reference: String, attributeName: String, aiValue: String, aideValue: String)

rel AiAsset(reference: String, commonName: String, hkey: String, locationRef: String, installedDate: String)
rel AideAsset(reference: String, commonName: String, hkey: String, locationRef: String, installedDate: String)
rel AssetDiff(reference: String, propertyName: String, aiValue: String, aideValue: String)

rel AssetNotInAide(reference: String, commonName: String)
rel AssetNotInAi(reference: String, commonName: String)
