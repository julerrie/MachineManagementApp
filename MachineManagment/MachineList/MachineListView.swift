//
//  MachineListView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/04/23.
//  Copyright © 2020 julerrie. All rights reserved.
//


//FIXME: warning message left

import SwiftUI

struct MachineListView: View {
    var codeString: String?
    @State var checkImage: String = "check_black"
    @State var searchString: String = ""
    @State var machineList: [MachineModel] = []
    @State var displayList: [MachineModel] = []
    @State var complete: Bool = false
    @State var finishedNum: Int = 0
    @State var isShowing: Bool = false
    @EnvironmentObject var userSettings: UserSettings
    func updateList(complete: Bool){
        self.displayList = []
        if complete || !searchString.isEmpty{
            for machine in machineList {
                var checkComplete: Bool = false
                var checkSearch: Bool = false
                if (complete && machine.complete == "0") || !complete {
                    checkComplete = true
                }
                if (!searchString.isEmpty && machine.managementId.contains(searchString) || machine.name.contains(searchString)) || (searchString.isEmpty) {
                    checkSearch = true
                }
                if checkSearch && checkComplete{
                    self.displayList.append(machine)
                }
            }
        } else{
            self.displayList = self.machineList
        }
    }
    
    func updateListInfo() {
        self.machineList = DBManager.sharedInstance.getMachineList()
        updateList(complete: self.complete)
        self.finishedNum = 0
        for machine in self.machineList {
            if machine.complete == "1" {
                finishedNum = finishedNum + 1
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20.0) {
            
            HStack(spacing: 80.0) {
                Button(action: {
                    if self.checkImage == "check_black" {
                        self.checkImage = "check_red"
                        self.complete = true
                    } else {
                        self.checkImage = "check_black"
                        self.complete = false
                    }
                    self.updateList(complete: self.complete)
                }) {
                    Image($checkImage.wrappedValue)
                        .resizable()
                }
                .frame(width: 30, height: 30)
                .buttonStyle(PlainButtonStyle())
                Text(userSettings.department)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text(String(self.finishedNum) + "/" + String(self.machineList.count))
                    .multilineTextAlignment(.trailing)
                
            }
            
            ZStack {
                TextField("", text: $searchString, onEditingChanged: { _ in
                    self.updateList(complete: self.complete)
                })
                    .padding(.horizontal, 20.0)
                    .frame(width: 300.0, height: 30.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 2)
                )
                    .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                Button(action: {
                    self.searchString = ""
                    self.updateList(complete: self.complete)
                }) {
                    Image("close")
                        .resizable()
                        .frame(width: 25.0, height: 25.0)
                }.padding(.leading, 250.0).buttonStyle(PlainButtonStyle())
            }
            
            List($displayList.wrappedValue) { model in
                MachineListCellView(machine: model, checkImage: model.complete == "0" ? "check_red" : "check_black")
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal, -35.0)
                    .padding(.vertical, -5.0)
                
            }
            Spacer()
        }
        .padding(.top, 50.0)
        .navigationBarTitle("機器台帳", displayMode: .inline)
        .onAppear {
            self.updateListInfo()
        }
        
    }
}

struct MachineListView_Previews: PreviewProvider {
    static var previews: some View {
        MachineListView()
    }
}
