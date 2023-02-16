//
//  DSKAuthView.swift
//  Mangareader (iOS)
//
//  Made on on 2022-08-11.
//

import RealmSwift
import SwiftUI

struct DSKAuthView: View {
    @StateObject var model: ViewModel

    var body: some View {
        LoadableView(model.runner.id, model.load, $model.loadable) { user in
            if let user {
                UserView(user: user)
            } else {
                AuthenticationGateway(runner: model.runner)
            }
        }
        .environmentObject(model)
    }
}

extension DSKAuthView {
    struct AuthenticationGateway: View {
        var runner: AnyRunner
        var method: RunnerIntents.AuthenticationMethod {
            runner.intents.authenticationMethod
        }

        var body: some View {
            Group {
                switch method {
                case .webview:
                    WebViewAuthView()
                case .basic:
                    BasicAuthView()
                case .oauth:
                    OAuthView()
                case .unknown:
                    Text("Authentication is improperly configured. Mangareader could not derive the authentication method your runner is using.")
                }
            }
        }
    }
}
