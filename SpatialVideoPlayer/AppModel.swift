//
//  AppModel.swift
//  SpatialVideoPlayer
//
//  Created by eiji.shirakazu on 2026/03/26.
//

import AVFoundation
import RealityKit
import SwiftUI

enum DemoImmersionStyleOption: String, CaseIterable, Identifiable {
    case mixed
    case progressive
    case full

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mixed:
            "Mixed"
        case .progressive:
            "Progressive"
        case .full:
            "Full"
        }
    }

    var headline: String {
        switch self {
        case .mixed:
            "現実空間を強く残したまま比較したいとき向け"
        case .progressive:
            "没入度を段階的に上げながら差分を見たいとき向け"
        case .full:
            "空間全体を映像体験に寄せて確認したいとき向け"
        }
    }

    var detail: String {
        switch self {
        case .mixed:
            "周囲の部屋を見ながら比較しやすいので、portal や screen の違いを把握しやすい構成です。"
        case .progressive:
            "空間全体の没入感をユーザーが段階的に調整でき、portal と full の中間的な印象を確認しやすくなります。"
        case .full:
            "現実空間の存在感を最小限にして、映像主導の体験として spatial 表示や full 表示を確認しやすくします。"
        }
    }

    var swiftUIStyle: any ImmersionStyle {
        switch self {
        case .mixed:
            return .mixed
        case .progressive:
            return .progressive
        case .full:
            return .full
        }
    }

    init(swiftUIStyle: any ImmersionStyle) {
        if swiftUIStyle is FullImmersionStyle {
            self = .full
        } else if swiftUIStyle is ProgressiveImmersionStyle {
            self = .progressive
        } else {
            self = .mixed
        }
    }
}

enum DemoPlayerImmersiveModeOption: String, CaseIterable, Identifiable {
    case portal
    case full
    case progressive

    var id: String { rawValue }

    var title: String {
        switch self {
        case .portal:
            "Portal"
        case .full:
            "Full"
        case .progressive:
            "Progressive"
        }
    }

    var headline: String {
        switch self {
        case .portal:
            "映像が開口部の向こうに広がる感覚"
        case .full:
            "映像が視界全体を支配する感覚"
        case .progressive:
            "portal から full へ段階的に広がる感覚"
        }
    }

    var detail: String {
        switch self {
        case .portal:
            "境界のある窓のように映像が広がるため、現実空間との比較や説明用途に向いています。"
        case .full:
            "境界を意識しにくくなり、映像体験への没入感が最も強くなります。"
        case .progressive:
            "没入の広がり方が連続的なので、視聴体験の変化量を伝えるデモに向いています。"
        }
    }

    var realityKitValue: VideoPlayerComponent.ImmersiveViewingMode {
        switch self {
        case .portal:
            .portal
        case .full:
            .full
        case .progressive:
            .progressive
        }
    }
}

enum DemoSpatialVideoModeOption: String, CaseIterable, Identifiable {
    case screen
    case spatial

    var id: String { rawValue }

    var title: String {
        switch self {
        case .screen:
            "Screen"
        case .spatial:
            "Spatial"
        }
    }

    var headline: String {
        switch self {
        case .screen:
            "平面スクリーンとして見る"
        case .spatial:
            "奥行き付きの空間映像として見る"
        }
    }

    var detail: String {
        switch self {
        case .screen:
            "通常の大画面表示に近い見え方で、構図や色、portal/full との組み合わせ比較がしやすくなります。"
        case .spatial:
            "被写体の前後感が強まり、空間ビデオらしい奥行き表現を確認しやすくなります。"
        }
    }

    var realityKitValue: VideoPlayerComponent.SpatialVideoMode {
        switch self {
        case .screen:
            .screen
        case .spatial:
            .spatial
        }
    }
}

/// Maintains app-wide state.
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    let sampleVideoURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/immersive-media/spatialLighthouseFlowersWaves/mvp.m3u8")!

    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }

    var immersiveSpaceState = ImmersiveSpaceState.closed
    var selectedAppImmersionStyle: DemoImmersionStyleOption = .mixed
    var selectedPlayerImmersiveMode: DemoPlayerImmersiveModeOption = .portal
    var selectedSpatialVideoMode: DemoSpatialVideoModeOption = .screen

    var actualPlayerImmersiveMode: VideoPlayerComponent.ImmersiveViewingMode?
    var actualSpatialVideoMode: VideoPlayerComponent.SpatialVideoMode?
    var renderingStatus: VideoPlayerComponent.RenderingStatus?
    var isPlaying = false

    private let player = AVPlayer()
    private var hasLoadedSampleItem = false

    init() {
        player.actionAtItemEnd = .pause
        player.automaticallyWaitsToMinimizeStalling = true
    }

    var canControlPlayback: Bool {
        immersiveSpaceState == .open
    }

    var playbackStateLabel: String {
        if immersiveSpaceState != .open {
            return "immersive space を開くと自動再生されます"
        }
        if let renderingStatus {
            switch renderingStatus {
            case .loading:
                return "ストリームを読み込み中"
            case .ready:
                break
            @unknown default:
                return isPlaying ? "再生中" : "一時停止"
            }
        }
        return isPlaying ? "再生中" : "一時停止"
    }

    var renderingStatusLabel: String {
        guard let renderingStatus else { return "未取得" }
        switch renderingStatus {
        case .loading:
            return "Loading"
        case .ready:
            return "Ready"
        @unknown default:
            return "Unknown"
        }
    }

    var actualPlayerImmersiveModeLabel: String {
        guard let actualPlayerImmersiveMode else { return "未取得" }
        switch actualPlayerImmersiveMode {
        case .portal:
            return "Portal"
        case .full:
            return "Full"
        case .progressive:
            return "Progressive"
        @unknown default:
            return "Unknown"
        }
    }

    var actualSpatialVideoModeLabel: String {
        guard let actualSpatialVideoMode else { return "未取得" }
        switch actualSpatialVideoMode {
        case .screen:
            return "Screen"
        case .spatial:
            return "Spatial"
        @unknown default:
            return "Unknown"
        }
    }

    var shouldHighlightActualModeDifference: Bool {
        actualPlayerImmersiveMode.map { $0 != selectedPlayerImmersiveMode.realityKitValue } == true
        || actualSpatialVideoMode.map { $0 != selectedSpatialVideoMode.realityKitValue } == true
    }

    var playerInstance: AVPlayer {
        preparePlayerIfNeeded()
        return player
    }

    func makeVideoPlayerComponent() -> VideoPlayerComponent {
        preparePlayerIfNeeded()
        var component = VideoPlayerComponent(avPlayer: player)
        component.desiredImmersiveViewingMode = selectedPlayerImmersiveMode.realityKitValue
        component.desiredSpatialVideoMode = selectedSpatialVideoMode.realityKitValue
        return component
    }

    func applySelections(to entity: Entity) {
        guard var component = entity.components[VideoPlayerComponent.self] else { return }
        component.desiredImmersiveViewingMode = selectedPlayerImmersiveMode.realityKitValue
        component.desiredSpatialVideoMode = selectedSpatialVideoMode.realityKitValue
        entity.components[VideoPlayerComponent.self] = component

        actualPlayerImmersiveMode = component.immersiveViewingMode
        actualSpatialVideoMode = component.spatialVideoMode
        renderingStatus = component.currentRenderingStatus
    }

    func captureCurrentComponentState(from entity: Entity) {
        guard let component = entity.components[VideoPlayerComponent.self] else { return }
        actualPlayerImmersiveMode = component.immersiveViewingMode
        actualSpatialVideoMode = component.spatialVideoMode
        renderingStatus = component.currentRenderingStatus
    }

    func preparePlayerIfNeeded() {
        guard !hasLoadedSampleItem else { return }
        player.replaceCurrentItem(with: AVPlayerItem(url: sampleVideoURL))
        hasLoadedSampleItem = true
    }

    func play() {
        preparePlayerIfNeeded()
        player.play()
        isPlaying = true
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func replay() {
        preparePlayerIfNeeded()
        player.seek(to: .zero)
        player.play()
        isPlaying = true
    }

    func clearRuntimeState() {
        isPlaying = false
        actualPlayerImmersiveMode = nil
        actualSpatialVideoMode = nil
        renderingStatus = nil
    }
}
