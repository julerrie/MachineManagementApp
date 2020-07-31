//
//  LoginView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/4/14.
//  Copyright © 2020 julerrie. All rights reserved.
//

//reference:
//https://developer.apple.com/documentation/localauthentication/logging_a_user_into_your_app_with_face_id_or_touch_id

import SwiftUI
import LocalAuthentication
import CoreNFC

struct LoginView: View {
    @State var title: String = "ログイン"
    @State var isLogin: Bool = false
    @State var userName: String = ""
    @State var password: String = ""
    @ObservedObject private var nfcReader: NFCReaderController = NFCReaderController()
    let server: String = "www.idnet.co.jp"
    
    var body: some View {
        NavigationView {
            
            VStack(alignment: .center, spacing: 80.0) {
                NFCReader(reader: self.nfcReader)
                NavigationLink(destination: MenuView(), isActive: $isLogin) {
                    EmptyView()
                }
//              .onAppear {
//                    self.isLogin = false
//                    self.nfcReader.startScanning()
//                    do {
//                        try self.readCredentials(server: self.server)
//                    } catch {
//                        if let error = error as? KeychainError {
//                            print(error.localizedDescription)
//                        }
//                    }
//                }
                
                
                VStack(alignment: .center) {
                    Text("機械管理アプリ")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20.0)
                    Text("Ver 1.0")
                        .font(.subheadline)
                }
                
                VStack(spacing: 20.0) {
                    TextField("社員番号", text: $userName)
                        .padding(.leading, 20.0)
                        .frame(width: 200.0, height: 40.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 2)
                    )
                    
                    
                    SecureField("パスワード", text: $password)
                        .padding(.leading, 20.0)
                        .frame(width: 200.0, height: 40.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 2)
                    )
                    
                }
                VStack(spacing: 20.0) {
                    
                    Button(action: {
                        self.isLogin = true
                        if !self.userName.isEmpty && !self.password.isEmpty {
                            do {
                                try self.addCredentials(Credentials(username: self.userName, password: self.password), server: self.server)
                            } catch {
                                if let error = error as? KeychainError {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }) {
                        Text("ログイン")
                            .foregroundColor(Color.green)
                            .frame(width: 200.0, height: 40.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 2)
                                
                        )
                    }
                    
                    Button(action: {
                        self.authenticate()
                    }) {
                        Text("顔また指紋でログイン")
                            .foregroundColor(Color.green)
                            .frame(width: 200.0, height: 40.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 2)
                        )
                    }
                    
                }
            }
            .padding(.bottom, 200.0)
            .onTapGesture {
                self.endEditing()
            }
        }
        .navigationBarTitle(Text($title.wrappedValue))
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "We need to unlock your data."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isLogin = true
                    } else {
                        self.isLogin = false
                    }
                }
            }
        } else {
            self.isLogin = false
        }
    }
    
    /// Reads the stored credentials for the given server.
    func readCredentials(server: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecUseOperationPrompt as String: "Access your password on the keychain",
                                    kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
        
        guard let existingItem = item as? [String: Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
            else {
                throw KeychainError(status: errSecInternalError)
        }
        self.userName = account
        self.password = password
    }
    
    func addCredentials(_ credentials: Credentials, server: String) throws {
        // Use the username as the account, and get the password as data.
        let account = credentials.username
        let password = credentials.password.data(using: String.Encoding.utf8)!
        
        // Create an access control instance that dictates how the item can be read later.
        let access = SecAccessControlCreateWithFlags(nil, // Use the default allocator.
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            .userPresence,
            nil) // Ignore any error.
        
        // Allow a device unlock in the last 10 seconds to be used to get at keychain items.
        let context = LAContext()
        context.touchIDAuthenticationAllowableReuseDuration = 10
        
        // Build the query for use in the add operation.
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: account,
                                    kSecAttrServer as String: server,
                                    kSecAttrAccessControl as String: access as Any,
                                    kSecUseAuthenticationContext as String: context,
                                    kSecValueData as String: password]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }
    
    func nfcProcess() {
        
    }
    
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct Credentials {
    var username: String
    var password: String
}

struct KeychainError: Error {
    var status: OSStatus
    
    var localizedDescription: String {
        return SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
    }
}
