//
//  SwiperView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/06/05.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI

struct SwiperView: View {
    let pages: [PageViewData]
    
    @Binding var index: Int
    @State private var offset: CGFloat = 0
    @State private var isUserSwiping: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(self.pages) { charType in
                        PageView(charType: charType)
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height)
                    }
                }
            }
            .content
            .offset(x: self.isUserSwiping ? self.offset : CGFloat(self.index) * -geometry.size.width)
            .frame(width: geometry.size.width, alignment: .leading)
        }
    }
}

