//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectHTTP
import PerfectLib
import PerfectHTTPServer
import PerfectMustache

// This 'handler' function can be referenced directly in the configuration below.
func handler(request: HTTPRequest, response: HTTPResponse) {
	// Respond with a simple message.
	response.setHeader(.contentType, value: "text/html")
	response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
	// Ensure that response.completed() is called when your processing is done.
	response.completed()
}

func helpRequestHandler (request: HTTPRequest, response: HTTPResponse) {
   
    
    // Ensure that response.completed() is called when your processing is done.
    response.completed()
}

struct MustacheHelper: MustachePageHandler {
    var values: MustacheEvaluationContext.MapType
    
    func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
        contxt.extendValues(with: values)
        do {
            try contxt.requestCompleted(withCollector: collector)
        } catch {
            let response = contxt.webResponse
            response.appendBody(string: "\(error)")
                .completed(status: .internalServerError)
        }
    }
}

func homePageHandler(request: HTTPRequest, response: HTTPResponse)  {
    var values = MustacheEvaluationContext.MapType()
    mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath:  request.documentRoot + "\hello.mustache")
    response.completed()
}

// Configuration data for an example server.
// This example configuration shows how to launch a server
// using a configuration dictionary.


let confData = [
	"servers": [
		// Configuration data for one server which:
		//	* Serves the hello world message at <host>:<port>/
		//	* Serves static files out of the "./webroot"
		//		directory (which must be located in the current working directory).
		//	* Performs content compression on outgoing data when appropriate.
		[
			"name":"localhost",
			"port":8080 ,
			"routes":[
				["method":"get", "uri":"/", "handler":handler],
                ["method":"post", "uri":"/post-request", "handler": helpRequestHandler],
				["method":"get", "uri":"/**", "handler": homePageHandler]
			],
			"filters":[
				[
				"type":"response",
				"priority":"high",
				"name":PerfectHTTPServer.HTTPFilter.contentCompression,
				]
			]
		]
	]
]

do {
	// Launch the servers based on the configuration data.
	try HTTPServer.launch(configurationData: confData)
} catch PerfectError.networkError(let error,let message) {
    fatalError("Error thrown: \(error) \(message)") // fatal error launching one of the servers
}

