//
//  KeyboardInputView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/04/21.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI

struct KeyboardInputView: View {
    @State var number: String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var machineModel: MachineModel = MachineModel()
    @State var showAlert: Bool = false
    @State var turnToDetailView: Bool = false
    @EnvironmentObject var userSettings: UserSettings
    var body: some View {
        VStack(alignment: .center, spacing: 30.0) {                VStack(spacing: 30.0) {
            Text(userSettings.department)
                .font(.headline)
            }
            HStack {
                TextField("資産管理番号", text: $number)
                    .padding(.horizontal, 20.0)
                    .frame(width: 200.0, height: 40.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 2)
                )
                NavigationLink(destination: OCRViewBuilder.make()) {
                    Image("ocr").resizable().frame(width: 40.0, height: 40.0)
                }.buttonStyle(PlainButtonStyle())
                
            }
            .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
            VStack(alignment: .center, spacing: 10.0) {
                HStack(spacing: 10.0) {
                    Button(action: {
                        self.number = self.number + "IN"
                    }) {
                        Text("IN")
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                    }
                    .frame(width: 70.0, height: 70.0)
                    .background(Color.init(.sRGB, red: 230/255, green: 230/255, blue: 230/255, opacity: 0.8))
                    Button(action: {
                        self.number = self.number + "1"
                    }) {
                        Text("1")
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                    }
                    .frame(width: 70.0, height: 70.0)
                    .background(Color.init(.sRGB, red: 230/255, green: 230/255, blue: 230/255, opacity: 0.8))
                    Button(action: {
                        self.number = self.number + "2"
                    }) {
                        Text("2")
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                    }
                    .frame(width: 70.0, height: 70.0)
                    .background(Color.init(.sRGB, red: 230/255, green: 230/255, blue: 230/255, opacity: 0.8))
                    Button(action: {
                        self.number = self.number + "3"
                    }) {
                        Text("3")
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                    }
                    .frame(width: 70.0, height: 70.0)
                    .background(Color.init(.sRGB, red: 230/255, green: 230/255, blue: 230/255, opacity: 0.8))
                }
                
                HStack(spacing: 10.0) {
                    Button(action: {
                        self.number = self.number + "-"
                    }) {
                        Text("-")
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                    }
                    .frame(width: 70.0, height: 70.0)
                    .background(Color.init(.sRGB, red: 230/255, green: 230/255, blue: 230/255, opacity: 0.8))
                    Button(action: {
                        self.number = self.number + "4"
                    }) {
                        Text("4")
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                    }
                    .frame(width: 70.0, height: 70.0)
                    .background(Color.init(.sRGB, red: 230/255, green: 230/255, blue: 230/255, opacity: 0.8))
                    Button(action: {
                        self.number = self.number + "5"
                    }) {
                        Text("5")
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                    }
                    .frame(width: 70.0, height: 70.0)
                    .background(Color.init(.sRGB, red: 230/255, green: 230/255, blue: 230/255, opacity: 0.8))
                    Button(action: {
                        self.number = self.number + "6"
                    }) {
                        Text("6")
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                    }
                    .frame(width: 70.0, height: 70.0)
                    .background(Color.init(.sRGB, red: 230/255, green: 230/255, blue: 230/255, opacity: 0.8))
                }
                
                HStack(spacing: 10.0) {
                    Rectangle()
                        .frame(width: 70, height: 70)
                        .hidden()
                    Button(action: {
                        self.number = self.number + "7"
                    }) {
                        Text("7")
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                    }
                    .frame(width: 70.0, height: 70.0)
                    .background(Color.init(.sRGB, red: 230/255, green: 230/255, blue: 230/255, opacity: 0.8))
                    Button(action: {
                        self.number = self.number + "8"
                    }) {
                        Text("8")
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                    }
                    .frame(width: 70.0, height: 70.0)
                    .background(Color.init(.sRGB, red: 230/255, green: 230/255, blue: 230/255, opacity: 0.8))
                    Button(action: {
                        self.number = self.number + "9"
                    }) {
                        Text("9")
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                    }
                    .frame(width: 70.0, height: 70.0)
                    .background(Color.init(.sRGB, red: 230/255, green: 230/255, blue: 230/255, opacity: 0.8))
                }
                
                HStack(spacing: 10.0) {
                    Button(action: {
                        if !self.number.isEmpty { self.number.removeLast()
                        }
                    }) {
                        Text("Back")
                            .font(.title)
                            .foregroundColor(Color.black)
                    }
                    .frame(width: 70.0, height: 70.0)
                    .background(Color.init(.sRGB, red: 230/255, green: 230/255, blue: 230/255, opacity: 0.8))
                    Rectangle()
                        .frame(width: 70, height: 70, alignment: .center)
                        .hidden()
                    Button(action: {
                        self.number = self.number + "0"
                    }) {
                        Text("0")
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                    }
                    .frame(width: 70.0, height: 70.0)
                    .background(Color.init(.sRGB, red: 230/255, green: 230/255, blue: 230/255, opacity: 0.8))
                    Rectangle()
                        .frame(width: 70, height: 70)
                        .hidden()
                    
                }
                .padding(.vertical, 5.0)
            }
            .padding(.vertical, 20.0)
            
            HStack(spacing: 20.0) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    Text("入力切替")
                        .foregroundColor(Color.green)
                        .frame(width: 120, height: 40.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 2)
                    )
                }
                NavigationLink(destination: DetailView(machine: machineModel, codeString:number), isActive: $turnToDetailView) {
                    EmptyView()
                }
                Button(action: {
                    self.checkDeviceExist(id: self.number)
                }) {
                    Text("確認")
                        .foregroundColor(Color.green)
                        .frame(width: 120, height: 40.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 2)
                    )
                }.alert(isPresented: $showAlert) { () -> Alert in
                    Alert(title: Text(""), message: Text("該当機器は存在しない"), dismissButton: .default(Text("OK"), action: {
                        self.showAlert = false
                    }))
                }
            }
            Spacer()
        }
        .onTapGesture {
            self.endEditing()
        }
        .padding(.top, 50.0)
        .navigationBarTitle("機器照合", displayMode: .inline)
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
    
    private func checkDeviceExist(id: String) {
        if let machineModel: MachineModel = DBManager.sharedInstance.getMachineBy(id: id) {
            self.machineModel = machineModel
            self.turnToDetailView = true
        } else {
            showAlert = true
        }
    }
}


struct KeyboardInputView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardInputView()
    }
}
