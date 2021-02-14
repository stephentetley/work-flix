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


namespace Skeleton/GenS4Lite {

    use AssetLib/S4Lite/CreateNew.Classifications;
    use Skeleton.GenMonad;

    
    pub def genOsgb36(gridRef: String): GenMonad[Classifications] = 
        use Skeleton/GenMonad.{flatMap, return, liftOption};
        let* ngr        = liftOption(AssetLib/Common/Osgb36.parse(gridRef), "Osgb36.parse");
        let* en         = liftOption(AssetLib/Common/Osgb36.toEastingNorthing(ngr), "Osgb36.toEastingNorthing");
        let easting     = AssetLib/S4Lite/CreateNew/Classifications.easting(en.easting);
        let northing    = AssetLib/S4Lite/CreateNew/Classifications.northing(en.northing);
        return(Monoid.combine(easting, northing))


}    