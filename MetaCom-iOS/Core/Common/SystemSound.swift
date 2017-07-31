//
//  SystemSound.swift
//  MetaCom-iOS
//
//  Created by Artem Chernenkiy on 31.07.2017.
//  Copyright © 2017 Metarhia. All rights reserved.
//

import UIKit
import AudioToolbox

func play(systemSoundID: Int) {
	
	guard let delegate = UIApplication.shared.delegate as? AppDelegate, delegate.isSoundEnabled == true else {
		return
	}
	
	let id = SystemSoundID(systemSoundID)
	AudioServicesPlaySystemSound(id)
}
