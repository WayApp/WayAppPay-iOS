//
//  ContentView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 11/24/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 1
 
    var body: some View {
        TabView(selection: $selection){
            Form {
                Section {
                /*@START_MENU_TOKEN@*/ /*@PLACEHOLDER=Section Content@*/Text("Section Content")/*@END_MENU_TOKEN@*/
            }
                .tabItem {
                    VStack {
                        Image("first")
                        Text("Coco")
                    }
                }
                .tag(0)

            }
            Text("First View")
                .font(.largeTitle)
                .tabItem {
                    VStack {
                        Image("first")
                        Text("Coco")
                    }
                }
                .tag(1)
            Text("Second View")
                .font(.title)
                .tabItem {
                    VStack {
                        Image("second")
                        Text("Second")
                    }
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
