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

namespace AssetLib/AssetModels/GeneralStructure/Datatypes {

    type alias GSSite = 
        { funcloc: String
        , name: String
        , status: String
        , functions: List[GSFunction]
        }


    type alias GSFunction = 
        { funcloc: String
        , name: String
        , objectType: String
        , status: String
        , processGroups: List[GSProcessGroup]
        }


    type alias GSProcessGroup = 
        { funcloc: String
        , name: String
        , objectType: String
        , status: String
        , processes: List[GSProcess]
        }

    type alias GSProcess = 
        { funcloc: String
        , name: String
        , objectType: String
        , status: String
        , systems: List[GSSystem]
        }

    type alias GSSystem = 
        { funcloc: String
        , name: String
        , objectType: String
        , status: String
        , subsystems: List[GSSubsystem]
        , equipment: List[GSEquipment]
        }


    type alias GSSubsystem = 
        { funcloc: String
        , name: String
        , objectType: String
        , status: String
        , equipment: List[GSEquipment]
        }


    type alias GSEquipment = 
        { equiId: String
        , name: String
        , objectType: String
        , status: String
        , position: Option[Int32]
        , subequipment: List[GSSubequipment]
        }

    type alias GSSubequipment = 
        { equiId: String
        , name: String
        , objectType: String
        , status: String
        , position: Option[Int32]
        }
        
}
