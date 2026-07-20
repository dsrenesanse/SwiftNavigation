//
//  SwiftNavigation.swift
//  SwiftNavigation
//
//  Created by Dan S on 2026/07/12.
//

import SwiftUI

@Observable
@MainActor
public final class Router {
    var path = [Route]()

    public func open<T: Sendable>(_ view: any View) async -> T? {
        await withCheckedContinuation({ continuation in
            let route = Route(
                view: AnyView(view),
                resume: { result in
                    continuation.resume(returning: result as? T)
                }
            )
            path.append(route)
        })
    }

    public func open(_ view: any View) async {
        await withCheckedContinuation({ continuation in
            let route = Route(
                view: AnyView(view),
                resume: { result in
                    continuation.resume()
                }
            )
            path.append(route)
        })
    }

    public func open(_ view: any View) {
        path.append(
            Route(
                view: AnyView(view),
                resume: { result in }
            )
        )
    }

    public func close<T>(_ result: T?) {
        guard !path.isEmpty else { return }
        let last = path.removeLast()
        last.result = result
    }

    public func close() {
        close(-1)
    }
}

class Route: Hashable, Equatable {
    let view: AnyView
    let resume: (Any?) -> Void
    let id = UUID().uuidString

    init(view: AnyView, resume: @escaping (Any?) -> Void) {
        self.view = view
        self.resume = resume
    }

    var result: Any?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Route, rhs: Route) -> Bool {
        return lhs.id == rhs.id
    }

    deinit {
        resume(result)
    }
}

public struct SwiftNavigation<Content: View>: View {
    @State private var router = Router()
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            content.navigationDestination(
                for: Route.self,
                destination: { route in
                    route.view
                }
            )
        }.environment(router)
    }
}
