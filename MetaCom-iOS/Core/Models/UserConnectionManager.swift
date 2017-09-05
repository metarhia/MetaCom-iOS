//
//  UserConnectionManager.swift
//  MetaCom-iOS
//
//  Created by Artem Chernenkiy on 17.05.17.
//  Copyright © 2017 Metarhia. All rights reserved.
//

import Foundation

/**
	A type representing a manager for user connections to various server hosts and ports.
*/
final class UserConnectionManager {
	
	/// Manager instance.
	public static let instance = UserConnectionManager()
	
	/// List of user connections.
	private(set) var userConnections: [UserConnection] = []
	
	/// Currently displayed connection.
	private weak var currentUserConnection: UserConnection?
	
	/**
		Represents current connection the user works with.
		Setting this property does nothing if the connection has been removed.
	*/
	public var currentConnection: UserConnection? {
		get {
			return currentUserConnection
		}
		set(connection) {
			
			guard let aConnection = connection, userConnections.contains(aConnection) else {
				if connection == nil {
					currentUserConnection = nil
				}
				return
			}
			
			currentUserConnection = aConnection
		}
	}
	
	/**
		Create new `UserConnectionManager` instance.
	*/
	private init() { }
	
	/**
		Establish new connection.
		- parameters:
			- host: server host.
			- port: server port.
			- callback: called on completion.
	*/
	func addConnection(host: String, port: Int, callback: @escaping (UserConnection?) -> Void) {
		
		let id = (userConnections.last?.id ?? -1) + 1
		let config = Configuration(host: host, port, true, Constants.applicationName, nil)
		let connection = UserConnection(identifier: id, configuration: config)
		
		let completion: (Error?) -> Void = { [weak self, unowned connection] error in
			
			guard error == nil else {
				self?.userConnections.remove(connection)
				return callback(nil)
			}
			
			callback(connection)
			UserDefaults.standard.set(["host" : host, "port" : port], forKey: "lastUserConnection")
		}
		
		userConnections.append(connection)
		connection.connect(with: completion)
	}
	
	/**
		Remove existing connection.
		- parameters:
			- connection: living connection.
	*/
	func removeConnection(_ connection: UserConnection) {
		userConnections.remove(connection)
	}
	
	/**
		Return last used user connection credentials.
		- returns: tuple containing last used host and port.
	*/
	func requestPreviousConnection() -> (host: String, port: Int)? {
		
		let saved = UserDefaults.standard.dictionary(forKey: "lastUserConnection")
		return saved == nil ? nil : (host: saved?["host"] as! String, port: saved?["port"] as! Int)
	}
}
