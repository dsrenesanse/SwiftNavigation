//
//  ContentView.swift
//  SwiftNavigationExample
//
//  Created by Dan on 20/07/2026.
//

import SwiftNavigation
import SwiftUI

struct ContentView: View {
    var body: some View {
        SwiftNavigation {
            Screen1()
        }
    }
}

struct Screen1: View {
    @Environment(Router.self) var router
    @State var sheet = false

    var body: some View {
        VStack {
            Button {
                router.openScreen2()
            } label: {
                Text("Lets go to screen A")
            }
            Button {
                sheet.toggle()
            } label: {
                Text("Open sheet with inner navigation")
            }.sheet(isPresented: $sheet) {
                InnerNavigation1()
            }
        }
        .navigationTitle("Screen 1")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InnerNavigation1: View {
    var body: some View {
        SwiftNavigation {
            Screen1()
        }
    }
}

struct Screen2: View {
    @Environment(Router.self) var router
    var body: some View {
        Button {
            router.close(45)
        } label: {
            Text("Lets go back and return 45 as result")
        }.navigationTitle("Screen 2")
    }
}

extension Router {
    func openScreen2() {
        Task {
            let result: Int? = await open(Screen2())
            //            assert(result == 45, "stuck here if we do not expect result, could be removed safely")
        }
    }
}

#Preview {
    ContentView()
}
