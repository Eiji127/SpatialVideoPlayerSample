//
//  SpatialVideoPlayerApp.swift
//  SpatialVideoPlayer
//
//  Created by eiji.shirakazu on 2026/03/26.
//

import SwiftUI

@main
struct EntryPoint: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(
            selection: Binding<any ImmersionStyle>(
                get: {
                    appModel.selectedAppImmersionStyle.swiftUIStyle
                },
                set: { newStyle in
                    appModel.selectedAppImmersionStyle = DemoImmersionStyleOption(swiftUIStyle: newStyle)
                }
            ),
            in: .mixed,
            .progressive,
            .full
        )
    }
}
