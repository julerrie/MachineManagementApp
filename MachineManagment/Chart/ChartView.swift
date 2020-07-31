//
//  ChartView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/06/05.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI
import SwiftUICharts
struct ChartView: View {
    var pages: [PageViewData] = []
    @EnvironmentObject var userSettings: UserSettings
    @State private var index: Int = 0

    init() {
        let machineList: [MachineModel] = DBManager.sharedInstance.getMachineList()
        var dict: [String: Int] = [:]
        for machine in machineList {
            if dict.keys.contains(machine.date) {
                dict[machine.date] = Int(dict[machine.date] ?? 0) + 1
            } else {
                dict[machine.date] = 1
            }
        }
        
        var data: [Double] = []
        var numOfDate: [(String, Int)] = []
        for item in dict {
            numOfDate.append((item.key, item.value))
        }
        numOfDate.sort(by:{ Int($0.0) ?? 0 < Int($1.0) ?? 0})
        for num in numOfDate {
            data.append(Double(num.1))
        }
        pages = [PageViewData(type: "Bar", displayData: numOfDate, data: data),
        PageViewData(type:"Line",displayData: numOfDate, data: data),
        PageViewData(type: "Pie",displayData: numOfDate, data: data),
        PageViewData(type: "Full",displayData: numOfDate, data: data)]
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 30.0) {
            VStack(spacing: 30.0) {
                Text(userSettings.department)
                    .font(.headline)
            }
            ZStack(alignment: .top) {
                SwiperView(pages: self.pages, index: self.$index)
                    .padding(.top, 0.0)
            }
            .frame(height: 500.0)
            Spacer()
            HStack(spacing: 8) {
                ForEach(0..<self.pages.count) { index in
                    PageButton(isSelected: Binding<Bool>(get: { self.index == index }, set: { _ in }), buttonName: self.pages[index].type) {
                        withAnimation {
                            self.index = index
                        }
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .padding(.top, 50.0)
        .navigationBarTitle("棚卸進捗確認", displayMode: .inline)
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
