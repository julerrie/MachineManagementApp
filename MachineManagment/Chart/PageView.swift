//
//  PageView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/06/05.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct PageViewData: Identifiable {
    let id: String = UUID().uuidString
    let type: String
    let displayData: [(String, Int)]
    let data: [Double]
}

struct PageView: View {
    let charType: PageViewData
    var body: some View {
        ZStack {
            if charType.type == "Bar" {
                BarCharts(displayData: charType.displayData)
            } else if charType.type == "Line" {
                LineCharts(data: charType.data)
            } else if charType.type == "Pie" {
                PieCharts(data: charType.data)
            } else {
                LineChartsFull(data: charType.data)
            }
        }
    }
}

struct BarCharts:View {
    var displayData: [(String, Int)]
    var body: some View {
        VStack{
            BarChartView(data: ChartData(values: displayData) , title: "棚卸数", style: Styles.barChartStyleOrangeLight, valueSpecifier: "%.0f")
        }
    }
}

struct LineCharts:View {
    var data: [Double]
    var body: some View {
        VStack{
            LineChartView(data: data, title: "棚卸数", valueSpecifier: "%.0f")
        }
    }
}

struct PieCharts:View {
    var data: [Double]
    var body: some View {
        VStack{
            PieChartView(data: data, title: "棚卸数")
        }
    }
}

struct LineChartsFull: View {
    var data: [Double]
    var body: some View {
        VStack{
            LineView(data: data, title: "棚卸数",valueSpecifier: "%.0f")
        }
    }
}
