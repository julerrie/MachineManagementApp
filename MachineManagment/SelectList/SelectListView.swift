//
//  SelectListView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/04/22.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI

struct SelectListView: View {
    @State var imageName: String = "new"
    @State var finishNum: String = "0"
    @State var allNum: String = "10"
    @EnvironmentObject var userSettings: UserSettings
    func countListNum() {
        let machineList: [MachineModel] = DBManager.sharedInstance.getMachineList()
        self.allNum = String(machineList.count)
        var count = 0
        for machine in machineList {
            if machine.complete == "1"{
                count = count + 1
            }
        }
        self.finishNum = String(count)
    }
    var body: some View {
        VStack(spacing: 40.0) {
            VStack(spacing: 30.0) {
                Text(userSettings.department)
                    .font(.headline)
            }
            VStack(alignment: .leading, spacing: 0.0) {
                NavigationLink(destination: FunctionSelectView()){
                    HStack() {
                        Image($imageName.wrappedValue).resizable()
                            .frame(width: 100.0, height: 100.0)
                        VStack(alignment: .leading, spacing: 5.0) {
                            HStack(spacing: 30.0) {
                                Text("2019年度　下期")
                                    .font(.headline)
                                Text(self.$finishNum.wrappedValue + "/" + self.$allNum.wrappedValue)
                                    .font(.headline)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100.0)
                            }
                            HStack {
                                Text("棚卸基準日：")
                                Text("2020/03/01（日）")
                            }
                            HStack {
                                Text("提出期限：")
                                Text("2020/03/19（木）")
                            }
                        }
                        .frame(width: 260.0)
                        Image("next").resizable()
                            .frame(width: 50.0, height: 50.0)
                    }
                    .frame(width: 412.0)
                    .border(Color.gray, width: 1)
                }.buttonStyle(PlainButtonStyle())
//                NavigationLink(destination: FunctionSelectView()) {
                    HStack() {
                        Image("finished").resizable()
                            .frame(width: 100.0, height: 100.0)
                        VStack(alignment: .leading, spacing: 5.0) {
                            HStack(spacing: 30.0) {
                                Text("2019年度　上期")
                                    .font(.headline)
                                Text("120/120")
                                    .font(.headline)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100.0)
                            }
                            HStack {
                                Text("棚卸基準日：")
                                Text("2020/09/01（日）")
                            }
                            HStack {
                                Text("提出期限：")
                                Text("2020/09/19（木）")
                            }
                        }
                        .frame(width: 260.0)
                        Image("next").resizable()
                            .frame(width: 50.0, height: 50.0)
                    }
                    .frame(width: 412.0)
                    .border(Color.gray, width: 1)
                }.buttonStyle(PlainButtonStyle())
//            }
            Spacer()
        }
        .padding(.top, 50.0)
        .navigationBarTitle("対象期間選択", displayMode: .inline)
        .onAppear {
            self.countListNum()
        }
    }
}

struct SelectListView_Previews: PreviewProvider {
    static var previews: some View {
        SelectListView()
    }
}
