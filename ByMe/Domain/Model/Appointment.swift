//
//  Appointment.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

struct Appointment: Codable, Identifiable {
    // Al usar @DocumentID, Firebase mapea el nombre del documento aquí
    @DocumentID var id: String?
    
    var userId: String = ""
    var professionalId: String = ""
    var professionalName: String = ""
    var serviceName: String = ""
    var date: Int64 = 0
    var status: String = "pending"
    var notes: String = ""
}
