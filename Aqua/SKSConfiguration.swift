//
//  SKSConfiguration.swift
//  Aqua
//
//  Created by Edgard Aguirre Rozo on 10/21/16.
//  Copyright © 2016 Edgard Aguirre Rozo. All rights reserved.
//

import Foundation

var SKSAppKey = "5f02571a173b9baf031d7631d4f88812043bbce03dcec6cf912b63a76ed86dcedac4e8f20083a103a01734750fbc8714f843f43511bb05a2e668495540b6231b"
var SKSAppId = "NMDPTRIAL_aguirrerozzo_gmail_com20161021153117"
var SKSServerHost = "sslsandbox-nmdp.nuancemobility.net"
var SKSServerPort = "443"
var SKSLanguage = "eng-USA"
var SKSServerUrl = String(format: "nmsps://%@@%@:%@", SKSAppId, SKSServerHost, SKSServerPort)
var SKSNLUContextTag = "!NLU_CONTEXT_TAG!"
let LANGUAGE = SKSLanguage == "!LANGUAGE!" ? "eng-USA" : SKSLanguage
