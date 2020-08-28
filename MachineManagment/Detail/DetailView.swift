//
//  DetailView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/4/20.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI

struct DetailView: View {
    var machine: MachineModel?
    var codeString: String?
    @State var systemTime: String = ""
    @State var showingAlert: Bool = false
    @State var buttonAvaliable: Bool = true
    @State var turnToMapView: Bool = false
    @EnvironmentObject var userSettings: UserSettings
    public func checkButtonAvaliable() {
        if self.machine?.complete == "0" {
            self.buttonAvaliable = true
        } else {
            self.buttonAvaliable = false
        }
    }
    
    public func initDateFormat() {
        let format: DateFormatter = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        self.systemTime = format.string(from: Date())
        
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 30.0) {
            VStack(spacing: 30.0) {
                Text(userSettings.department)
                    .font(.headline)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 10.0) {
                    Text("資産管理番号：")
                        .multilineTextAlignment(.leading)
                    Text("機器種別：")
                        .multilineTextAlignment(.leading)
                    Text("機器名：")
                        .multilineTextAlignment(.leading)
                    Text("部署名：")
                        .multilineTextAlignment(.leading)
                    Text("グールプ名：")
                        .multilineTextAlignment(.leading)
                    Text("設置場所：")
                        .multilineTextAlignment(.leading)
                    Text("建物備考：")
                        .multilineTextAlignment(.leading)
                    Text("使用者ID：")
                        .multilineTextAlignment(.leading)
                    Text("使用者名：")
                        .multilineTextAlignment(.leading)
                }
                VStack(alignment: .trailing, spacing: 10.0) {
                    Text(machine?.managementId ?? codeString ?? "")
                        .multilineTextAlignment(.trailing)
                    Text(machine?.type ?? "ノートPC")
                        .multilineTextAlignment(.trailing)
                    Text(machine?.name ?? "LifeBook")
                        .multilineTextAlignment(.trailing)
                    Text(machine?.department ?? "先端技術部")
                        .multilineTextAlignment(.trailing)
                    Text(machine?.group ?? "先端技術A")
                        .multilineTextAlignment(.trailing)
                    Text(machine?.address ?? "本社")
                        .multilineTextAlignment(.trailing)
                    Text(machine?.remark ?? "YSビール１F")
                        .multilineTextAlignment(.trailing)
                    Text(machine?.userId ?? "6448")
                        .multilineTextAlignment(.trailing)
                    Text(machine?.userName ?? "ルオ　ラン")
                        .multilineTextAlignment(.trailing)
                }
            }
            .frame(width: 300.0)
            Divider()
                .padding(.horizontal, 10.0)
                .frame(height: 2.0)
            
            HStack {
                VStack(alignment: .leading, spacing: 10.0) {
                    Text("照合日時：")
                        .multilineTextAlignment(.leading)
                    Text("照合者名：")
                        .multilineTextAlignment(.leading)
                }
                VStack(alignment: .trailing, spacing: 10.0) {
                    Text(self.systemTime)
                        .multilineTextAlignment(.trailing)
                    Text("ルオ　ラン")
                        .multilineTextAlignment(.trailing)
                }
            }
            .frame(width: 300.0)
            if self.$buttonAvaliable.wrappedValue {
                Button(action: {
                    self.showingAlert = true
                    DBManager.sharedInstance.updataDBWith(id: self.machine?.managementId ?? "")
                }) {
                    Text("確認")
                }.alert(isPresented: $showingAlert, content: {
                    Alert(title: Text(""), message: Text("登録が完了しました。"), dismissButton: .default(Text("OK"), action: {
                        self.buttonAvaliable = false
                    }))
                })
                    .foregroundColor(Color.green)
                    .frame(width: 250, height: 40.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 2))
            }
            if !(machine?.worldMapx ?? "").isEmpty && !(machine?.worldMapy ?? "").isEmpty {
                Button(action: {
                    self.turnToMapView = true
                }) {
                    Text("位置を確認する")
                }
                    .foregroundColor(Color.green)
                    .frame(width: 250, height: 40.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 2))
            }
            NavigationLink(destination: MapDirectionView(fromDetail: true, showAlert:true, machine: machine).environmentObject(MotionManager()), isActive: $turnToMapView) {
                EmptyView()
            }
            Spacer()
        }
        .padding(.top, 50.0)
        .navigationBarTitle("機器照合", displayMode: .inline)
        .onAppear {
            self.checkButtonAvaliable()
            self.initDateFormat()
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(machine: nil, codeString: "123456")
    }
}
