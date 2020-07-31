//
//  functionSelect.swift
//  MachineManagment
//
//  Created by julerrie on 2020/04/22.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI


struct FunctionSelectView: View {
    @EnvironmentObject var userSettings: UserSettings
    var body: some View {
        VStack(spacing: 40.0) {
            VStack(spacing: 30.0) {
                Text(userSettings.department)
                    .font(.headline)
            }
            VStack(alignment: .leading, spacing: 0.0) {
                NavigationLink(destination: BarcodeScanView()) {
                    HStack(spacing: 50.0) {
                        VStack(alignment: .leading) {
                            Text("機器を照合する")
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                            Text("資産管理番号を読み取りまたは入力して機器を照合します")
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .frame(height: 60.0)
                        }
                        .frame(width: 300.0, height: 100.0)
                        Image("next").resizable()
                            .frame(width: 50.0, height: 50.0)
                    }
                    .frame(width: 412.0)
                    .border(Color.gray, width: 1)
                }.buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: MachineListView()) {
                    HStack(spacing: 50.0) {
                        VStack(alignment: .leading) {
                            Text("台帳を確認する")
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                            Text("部署が所有する機器の台帳を確認します")
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .frame(height: 60.0)
                        }
                        .frame(width: 300.0, height: 100.0)
                        Image("next").resizable()
                            .frame(width: 50.0, height: 50.0)
                    }
                    .frame(width: 412.0)
                    .border(Color.gray, width: 1)
                }.buttonStyle(PlainButtonStyle())
            }
            Spacer()
        }
        .padding(.top, 50.0)
        .navigationBarTitle("業務選択", displayMode: .inline)
        
    }
}

struct FunctionSelectView_Previews: PreviewProvider {
    static var previews: some View {
        FunctionSelectView()
    }
}
