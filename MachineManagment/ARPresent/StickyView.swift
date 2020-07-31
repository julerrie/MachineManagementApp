//
//  StickyView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/06/05.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI

struct StickyView: View {
    var body: some View {
        Group {
            Text("GeometryReaderのお勉強。これをマスターすると実現できることが広がりそう。")
                .frame(width: 200, height: 200)
                .lineLimit(10)
                .fixedSize(horizontal: true, vertical: false)
                .background(StickyNoteView())
        }
    }
}

struct StickyNoteView: View {
    var color: Color = .green
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    let w = geometry.size.width
                    let h = geometry.size.height
                    let m = min(w/5, h/5)
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: h))
                    path.addLine(to: CGPoint(x: w-m, y: h))
                    path.addLine(to: CGPoint(x: w, y: h-m))
                    path.addLine(to: CGPoint(x: w, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                }
                .fill(self.color)
                Path { path in
                    let w = geometry.size.width
                    let h = geometry.size.height
                    let m = min(w/5, h/5)
                    path.move(to: CGPoint(x: w-m, y: h))
                    path.addLine(to: CGPoint(x: w-m, y: h-m))
                    path.addLine(to: CGPoint(x: w, y: h-m))
                    path.addLine(to: CGPoint(x: w-m, y: h))
                }
                .fill(Color.black).opacity(0.4)
            }
        }
    }
}

struct StickyView_Previews: PreviewProvider {
    static var previews: some View {
        StickyView()
    }
}
