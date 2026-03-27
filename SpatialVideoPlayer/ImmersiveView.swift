//
//  ImmersiveView.swift
//  SpatialVideoPlayer
//
//  Created by eiji.shirakazu on 2026/03/26.
//

import RealityKit
import SwiftUI

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel

    @State private var videoEntity: Entity?
    @State private var eventSubscriptions: [EventSubscription] = []

    var body: some View {
        RealityView { content in
            cancelSubscriptions()

            let videoEntity = Entity()
            videoEntity.position = [0, 1.35, -1.8]
            videoEntity.components[VideoPlayerComponent.self] = appModel.makeVideoPlayerComponent()
            content.add(videoEntity)

            self.videoEntity = videoEntity
            appModel.captureCurrentComponentState(from: videoEntity)

            var subscriptions: [EventSubscription] = []

            subscriptions.append(
                content.subscribe(to: VideoPlayerEvents.ImmersiveViewingModeDidChange.self, on: videoEntity) { event in
                    Task { @MainActor in
                        appModel.actualPlayerImmersiveMode = event.currentMode
                    }
                }
            )

            subscriptions.append(
                content.subscribe(to: VideoPlayerEvents.SpatialVideoModeDidChange.self, on: videoEntity) { event in
                    Task { @MainActor in
                        appModel.actualSpatialVideoMode = event.currentMode
                    }
                }
            )

            subscriptions.append(
                content.subscribe(to: VideoPlayerEvents.RenderingStatusDidChange.self, on: videoEntity) { event in
                    Task { @MainActor in
                        appModel.renderingStatus = event.currentStatus
                    }
                }
            )

            eventSubscriptions = subscriptions
            appModel.play()
        } update: { _ in
            guard let videoEntity else { return }
            appModel.applySelections(to: videoEntity)
        } placeholder: {
            ProgressView("空間ビデオを読み込み中...")
        }
        .onDisappear {
            cancelSubscriptions()
            videoEntity = nil
            appModel.pause()
            appModel.clearRuntimeState()
        }
    }

    private func cancelSubscriptions() {
        eventSubscriptions.forEach { $0.cancel() }
        eventSubscriptions.removeAll()
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
