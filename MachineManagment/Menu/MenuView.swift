//
//  MenuView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/4/15.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI


struct MenuView: View {
    @EnvironmentObject var userSettings: UserSettings
    var body: some View {
        VStack(spacing: 40.0) {
            VStack(spacing: 30.0) {
                Text(userSettings.department)
                    .font(.headline)
            }
            VStack(alignment: .leading, spacing: 0.0) {
                NavigationLink(destination: BarcodeScanViewBuilder.make()) {
                    HStack(spacing: 1.0) {
                        Image("development").resizable()
                            .frame(width: 100.0, height: 100.0)
                        VStack(alignment: .leading) {
                            Text("機器を照合する")
                                .multilineTextAlignment(.leading)
                            Text("資産管理番号を読み取りまたは入力して機器を照合します")
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .frame(height: 60.0)
                        }
                        .frame(width: 250.0)
                        Image("next").resizable()
                            .frame(width: 50.0, height: 50.0)
                    }
                    .frame(width: 412.0)
                    .border(Color.gray, width: 1)
                }.buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: SelectListView()) {
                    HStack() {
                        Image("list").resizable()
                            .frame(width: 100.0, height: 100.0)
                        VStack(alignment: .leading) {
                            Text("機器を棚卸する")
                                .multilineTextAlignment(.leading)
                            Text("各事業場の機器を台帳と照合します")
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .frame(height: 60.0)
                        }
                        .frame(width: 250.0)
                        Image("next").resizable()
                            .frame(width: 50.0, height: 50.0)
                    }
                    .frame(width: 412.0)
                    .border(Color.gray, width: 1)
                }.buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: ChangeDepartmentView()) {
                    HStack() {
                        Image("electrical-service").resizable()
                            .padding(.leading, 0.0)
                            .frame(width: 100.0, height: 100.0)
                        VStack(alignment: .leading) {
                            Text("部署を変更する")
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 0.0)
                            Text("棚卸する部署を変更します        ")
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                                .padding(.leading, 0.0)
                                .frame(height: 60.0)
                        }
                        .padding(0.0)
                        .frame(width: 250.0)
                        Image("next").resizable()
                            .padding(.trailing, 0.0)
                            .frame(width: 50.0, height: 50.0)
                    }
                    .frame(width: 412.0)
                    .border(Color.gray, width: 1)
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: ARPresentViewBuilder.make(fromMenu: true)) {
                    HStack() {
                        Image("technology").resizable()
                            .padding(.leading, 0.0)
                            .frame(width: 100.0, height: 100.0)
                        VStack(alignment: .leading) {
                            Text("機器位置を確認する")
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 0.0)
                            Text("機器の位置をARで確認します        ")
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                                .padding(.leading, 0.0)
                                .frame(height: 60.0)
                        }
                        .padding(0.0)
                        .frame(width: 250.0)
                        Image("next").resizable()
                            .padding(.trailing, 0.0)
                            .frame(width: 50.0, height: 50.0)
                    }
                    .frame(width: 412.0)
                    .border(Color.gray, width: 1)
                }.buttonStyle(PlainButtonStyle())
                NavigationLink(destination: ChartView()) {
                    HStack() {
                        Image("chart").resizable()
                            .padding(.leading, 0.0)
                            .frame(width: 100.0, height: 100.0)
                        VStack(alignment: .leading) {
                            Text("棚卸進捗を確認する")
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 0.0)
                            Text("棚卸の状況をチャットで確認します")
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                                .padding(.leading, 0.0)
                                .frame(height: 60.0)
                        }
                        .padding(0.0)
                        .frame(width: 250.0)
                        Image("next").resizable()
                            .padding(.trailing, 0.0)
                            .frame(width: 50.0, height: 50.0)
                    }
                    .frame(width: 412.0)
                    .border(Color.gray, width: 1)
                }.buttonStyle(PlainButtonStyle())
            }
            Spacer()
        }
        .padding(.top, 50.0)
        .navigationBarTitle("メニュー", displayMode: .inline)
    }
}



struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
