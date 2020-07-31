//
//  MachineListCellView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/04/23.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI

struct MachineListCellView: View {
    var machine: MachineModel?
    var today: String = ""
    @State var checkImage: String = "check_red"
    public func updateImage() {
        if self.machine?.complete == "0" {
            self.checkImage = "check_red"
        } else {
            self.checkImage = "check_black"
        }
    }
    
    init(machine: MachineModel, checkImage: String) {
        self.machine = machine
        self.checkImage = checkImage
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        today = formatter.string(from: date)
    }
    var body: some View {
        NavigationLink(destination: DetailView(machine: machine)) {
            HStack() {
                
                VStack {
                    if self.checkImage == "check_black" {
                        Text("済")
                    } else {
                        Text("未")
                    }
                    Image($checkImage.wrappedValue).resizable()
                        .frame(width: 25.0, height: 25.0)
                }
                VStack(alignment: .leading, spacing: 5.0) {
                    HStack(spacing: 10.0) {
                        VStack(alignment: .leading, spacing: 5.0) {
                            Text("資産管理番号：")
                                .multilineTextAlignment(.leading)
                            Text("機器種別：")
                                .multilineTextAlignment(.leading)
                            Text("機器名：")
                                .multilineTextAlignment(.leading)
                            Text("設置場所：")
                                .multilineTextAlignment(.leading)
                            Text("照合日時：")
                                .multilineTextAlignment(.leading)
                            Text("照合者名：")
                                .multilineTextAlignment(.leading)
                        }
                        VStack(alignment: .leading, spacing: 5.0) {
                            Text(machine?.managementId ??  String("12345678"))
                                .multilineTextAlignment(.trailing)
                            Text(machine?.type ?? "ノートPC")
                                .multilineTextAlignment(.trailing)
                            Text(machine?.name ?? "LifeBook")
                                .multilineTextAlignment(.trailing)
                            Text(machine?.address ?? "本社")
                                .multilineTextAlignment(.trailing)
                            Text(machine?.date ?? today)
                                .multilineTextAlignment(.trailing)
                            Text("ルオ　ラン")
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                .frame(width: 260.0)
                Image("next").resizable()
                    .frame(width: 50.0, height: 50.0)
            }
            .padding(.vertical, 5.0)
            .frame(maxWidth: .infinity)
            .border(Color.gray, width: 1)
        }.onAppear {
            self.updateImage()
        }
    }
}

//struct MachineListCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        MachineListCellView()
//    }
//}
