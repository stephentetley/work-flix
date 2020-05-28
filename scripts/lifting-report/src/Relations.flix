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

use Time.LocalDate;

namespace LiftingReport/Relations {

    pub enum FixedOrPortable {
        case Fixed,
        case Portable
    }

    pub def readFixedOrPortable(s: String): Result[FixedOrPortable, System.Error] = 
        match String.trim(String.toLowerCase(s)) {
            case "fixed" => Ok(Fixed)
            case "portable" => Ok(Portable)
            case _ => Err(System/Error.Generic("FixedOrPortable"))
        }

    rel EquiMatch(aiName: String, containsList: List[String], s4ObjType: String, s4Class: String, fop: FixedOrPortable)

    rel MemoLine(pliCode: String, text:String)

    rel EquipmentInfo(index: Int32, pliCode: String, commonName: String, installedDate: LocalDate,                        
            manufacturer: String, model:String, specificModel: String, 
            serialNumber: String, locationOnSite: String, workLoad: Int32, 
            worlLoadUnits: String, ywRef: String, testCert: String)



    rel Answer(index: Int32, pliCode: String, s4Name: String, category: String, maint: String, objType: String, classification: String, memo: String)

    /// A "cell printer" for the body of Answer.
    pub def answerCells(src: (Int32, String, String, String, String, String, String, String)): Array[String] & Impure = 
        let (index, pliCode, s4Name, category, maint, objType, classification, memoline) = src;
        [ Int32.toString(index), pliCode, s4Name, category, maint, objType, classification, memoline ]

    pub def answerHeaders(): Array[String] & Impure = 
        [ "Index", "PLI Code", "EQuipment Name", "Category", "Maint", "Obj Type", "Classification", "Memo Line"] 

    pub def writeReport(relns: #{ Answer}, dest: String): Result[Unit, System.Error] & Impure =  
        let buildStep = FactIO/CsvExport.makeBuildStep(answerCells); 
        let builder: FactIO.CsvBuilder = fold Answer FactIO/CsvExport.emptyCsvBuilder() buildStep relns;
        FactIO/CsvExport.outputCsv(dest, Text/Charset.utf_8(), answerHeaders(), builder)

}