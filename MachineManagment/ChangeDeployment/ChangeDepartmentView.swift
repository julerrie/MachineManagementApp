//
//  ChangeDepartmentView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/06/15.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI

struct ChangeDepartmentView: View {
    @State var showingAlert: Bool = false
    //@State var finishedChange: Bool = false
    @State var selectedItem: String = ""
    @EnvironmentObject var userSettings: UserSettings
    var body: some View {
        VStack(spacing: 20.0) {
            VStack(spacing: 30.0) {
                Text(userSettings.department)
                    .font(.headline)
            }
//            .alert(isPresented: self.$finishedChange, content: {
//                Alert(title: Text(""), message: Text("変更が完了しました"), dismissButton: .default(Text("OK"), action: {
//                    self.finishedChange = false
//                }))
//            })
            VStack {
                List(Department.allCases) { item in
                    Button(action: {
                        self.showingAlert = true
                        self.selectedItem = item.rawValue
                    }) {
                        Text(String(describing: item))
                            .padding(.leading, 20.0)
                    }
                }
            }
            .alert(isPresented: self.$showingAlert, content: {
                Alert(title: Text(""), message: Text("部署を変更しますか？"), primaryButton: .default(Text("いいえ"), action: {
                    self.showingAlert = false
                }), secondaryButton: .default(Text("はい"), action: {
                    self.showingAlert = false
                    //self.finishedChange = true
                    self.userSettings.department = self.selectedItem
                    UserDefaults.standard.set(self.selectedItem, forKey: "department")
                }))
            })
            Spacer()

        }
        .padding(.top, 50.0)
        .navigationBarTitle("対象部署変更", displayMode: .inline)
    }
}

struct ChangeDepartmentView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeDepartmentView()
    }
}
