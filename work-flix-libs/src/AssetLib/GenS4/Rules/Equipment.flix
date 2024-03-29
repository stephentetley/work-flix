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

namespace AssetLib/GenS4/Rules/Equipment {

    use Compatibility.{XlsxSource};
    
    use AssetLib/S4Lite/Datatypes.{SLEquipment, SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{Equipment, EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String};
    use AssetLib/GenS4/Base/OrderedStrings.{OrderedStrings};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, LocationOnSite, AibMemoLine};
    use AssetLib/GenS4/AibFacts/Attributes/Equipment.{EquipmentAttributes};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    


    /// # Equipment


    pub def genEquis(attribs: List[EquipmentAttributes], xs: List[EquiWorkItem]): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, liftAction, liftResult, mapX, tellSLEquipment};
        let* patches    = liftResult(_ -> AssetLib/GenS4/Patch.makeEquipmentAttributesPatches(attribs) |> Ok);
        let* today      = liftAction(_ -> Time/LocalDate.now());
        let* answers    = liftResult(_ -> List.map(genEqui1(today), xs) 
                                                    |> AssetLib/GenS4/Patch.patchEquipment(patches));
        mapX(tellSLEquipment, answers)    


    def genEqui1(today: Time.LocalDate, x: EquiWorkItem): SLEquipment =
        { equiId                = x.equipmentId
        , category              = x.s4Category              /// e.g "M", "I", "E"
        , description           = String.takeLeft(40, x.s4Name)
        , validFrom             = today         /// Should remain `today`.
        , objectType            = x.s4EquiType
        , weightKg              = None
        , startupDate           = today         /// Should be "patched"
        , manufacturer          = x.manufacturer
        , model                 = x.model
        , partNumber            = ""
        , serialNumber          = "UNKNOWN"
        , functionalLocation    = x.s4Floc
        , superOrdinateEqui     = x.superEquiId
        , position              = x.position
        , techIdentNo           = ""
        , status                = "UCON"
        }


    
    /// # Characteristics
    pub def genCommonCharacteristics(worklist: List[EquiWorkItem], locationSrc: XlsxSource, memoSrc: XlsxSource): GenMonad[Unit] =
        use AssetLib/GenS4/GenMonad.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(worklist);
        let* locFacts   = AssetLib/GenS4/AibFacts/Attributes/LocationData.readLocationOnSiteData(locationSrc);
        let* memoFacts  = AssetLib/GenS4/AibFacts/Attributes/MemoLines.readMemoLinesData(memoSrc);
        equiCommonCharacteristics(workitems <+> locFacts <+> memoFacts)



    pub def equiCommonCharacteristics(input: #{EquiWorkItem3,
                                            LocationOnSite, AibMemoLine, EquiCharacteristic| r1}): GenMonad[Unit] =
        let rules = #{
            
            EquiCharacteristic(equiId, s4EquiClass, "UNICLASS_CODE", S4String("")) :- 
                EquiWorkItem3(equiId, _, s4EquiClass).

            EquiCharacteristic(equiId, s4EquiClass, "UNICLASS_DESC", S4String("")) :-
                EquiWorkItem3(equiId, _, s4EquiClass).

            EquiCharacteristic(equiId, s4EquiClass, "LOCATION_ON_SITE", S4String(s4Location(location))) :-
                EquiWorkItem3(equiId, _, s4EquiClass),
                LocationOnSite(equiId, location).

           EquiCharacteristic(equiId, s4EquiClass, "MEMO_LINE", S4String(s4MemoLine(body))) :-
                EquiWorkItem3(equiId, _, s4EquiClass),
                fix AibMemoLine(equiId; body).

        };
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(rules <+> input)

    def s4Location(s: String): String =
        if (String.length(s) > 30) "SEE LONG TEXT" else s

    def s4MemoLine(s: OrderedStrings): String = 
        let text = AssetLib/GenS4/Base/OrderedStrings.getValue(s);
        if (AssetLib/GenS4/Base/OrderedStrings.count(s) > 1 or String.length(text) >= 30)
            "SEE LONG TEXT"
        else
            text


}

