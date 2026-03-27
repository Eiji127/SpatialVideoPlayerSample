//
//  ContentView.swift
//  SpatialVideoPlayer
//
//  Created by eiji.shirakazu on 2026/03/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel

    private let comparisonChecklist = [
        "1. App の ImmersionStyle を変えて、空間全体の没入度がどう変わるかを見る",
        "2. Portal / Full / Progressive を切り替えて、映像の包まれ方の違いを見る",
        "3. Screen / Spatial を切り替えて、奥行き感の有無を見比べる"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard
                controlsCard
                statusCard
                playbackCard
                explanationCards
            }
            .frame(maxWidth: 980, alignment: .leading)
            .padding(28)
        }
        .background(Color(red: 0, green: 169 / 255.0, blue: 224.0 / 255.0))
    }

    private var headerCard: some View {
        DemoCard(title: "Spatial Video Player Playground", subtitle: "Apple 提供の空間ビデオを使って、App の没入スタイルと VideoPlayerComponent の表示差分をその場で比較します。") {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(comparisonChecklist, id: \.self) { item in
                    Text(item)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("再生ソース")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text(appModel.sampleVideoURL.absoluteString)
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .textSelection(.enabled)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
        }
    }

    private var controlsCard: some View {
        DemoCard(title: "比較コントロール", subtitle: "3 軸を独立に切り替えます。immersive space を開いたまま変更して actual state を見比べてください。") {
            VStack(alignment: .leading, spacing: 18) {
                DemoPickerRow(
                    title: "App ImmersionStyle",
                    detail: appModel.selectedAppImmersionStyle.headline,
                    selection: Bindable(appModel).selectedAppImmersionStyle,
                    options: DemoImmersionStyleOption.allCases
                )

                DemoPickerRow(
                    title: "Player ImmersiveViewingMode",
                    detail: appModel.selectedPlayerImmersiveMode.headline,
                    selection: Bindable(appModel).selectedPlayerImmersiveMode,
                    options: DemoPlayerImmersiveModeOption.allCases
                )

                DemoPickerRow(
                    title: "SpatialVideoMode",
                    detail: appModel.selectedSpatialVideoMode.headline,
                    selection: Bindable(appModel).selectedSpatialVideoMode,
                    options: DemoSpatialVideoModeOption.allCases
                )

                ToggleImmersiveSpaceButton()
            }
        }
    }

    private var statusCard: some View {
        DemoCard(title: "Actual State", subtitle: "要求した mode と、RealityKit が実際に反映した mode を見比べるためのステータスです。") {
            VStack(alignment: .leading, spacing: 16) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 14)], spacing: 14) {
                    StatusTile(
                        title: "App Style",
                        desiredValue: appModel.selectedAppImmersionStyle.title,
                        actualValue: appModel.selectedAppImmersionStyle.title,
                        footer: appModel.immersiveSpaceState == .open ? "現在の immersive space に適用中" : "immersive space は未オープン"
                    )

                    StatusTile(
                        title: "Player Immersive",
                        desiredValue: appModel.selectedPlayerImmersiveMode.title,
                        actualValue: appModel.actualPlayerImmersiveModeLabel,
                        footer: "portal / full / progressive"
                    )

                    StatusTile(
                        title: "Spatial Mode",
                        desiredValue: appModel.selectedSpatialVideoMode.title,
                        actualValue: appModel.actualSpatialVideoModeLabel,
                        footer: "screen / spatial"
                    )

                    StatusTile(
                        title: "Rendering",
                        desiredValue: appModel.playbackStateLabel,
                        actualValue: appModel.renderingStatusLabel,
                        footer: "RealityKit の描画ステータス"
                    )
                }

                if appModel.shouldHighlightActualModeDifference {
                    Text("要求値と actual state が異なる場合は、ランタイム条件や空間条件に応じて system が別の mode を適用している可能性があります。")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.orange)
                        .padding(.top, 2)
                }
            }
        }
    }

    private var playbackCard: some View {
        DemoCard(title: "再生コントロール", subtitle: "immersive space を開くと自動再生します。比較中に pause / replay だけ手元で切り替えられるようにします。") {
            HStack(spacing: 12) {
                Button("再生") {
                    appModel.play()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!appModel.canControlPlayback)

                Button("一時停止") {
                    appModel.pause()
                }
                .buttonStyle(.bordered)
                .disabled(!appModel.canControlPlayback)

                Button("先頭から再生") {
                    appModel.replay()
                }
                .buttonStyle(.bordered)
                .disabled(!appModel.canControlPlayback)

                Spacer(minLength: 0)

                Text(appModel.playbackStateLabel)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var explanationCards: some View {
        DemoCard(title: "見どころ", subtitle: "今選んでいる 3 つの mode で、どこを見ると違いが分かりやすいかをまとめています。") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 16)], spacing: 16) {
                ExplanationTile(
                    eyebrow: "App ImmersionStyle",
                    title: appModel.selectedAppImmersionStyle.title,
                    headline: appModel.selectedAppImmersionStyle.headline,
                    detail: appModel.selectedAppImmersionStyle.detail
                )

                ExplanationTile(
                    eyebrow: "Player ImmersiveViewingMode",
                    title: appModel.selectedPlayerImmersiveMode.title,
                    headline: appModel.selectedPlayerImmersiveMode.headline,
                    detail: appModel.selectedPlayerImmersiveMode.detail
                )

                ExplanationTile(
                    eyebrow: "SpatialVideoMode",
                    title: appModel.selectedSpatialVideoMode.title,
                    headline: appModel.selectedSpatialVideoMode.headline,
                    detail: appModel.selectedSpatialVideoMode.detail
                )
            }
        }
    }
}

private struct DemoCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            content
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private struct DemoPickerRow<Option: CaseIterable & Hashable & Identifiable & RawRepresentable>: View where Option.RawValue == String {
    let title: String
    let detail: String
    @Binding var selection: Option
    let options: Option.AllCases

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            Picker(title, selection: $selection) {
                ForEach(Array(options)) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            }
            .pickerStyle(.segmented)

            Text(detail)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

private struct StatusTile: View {
    let title: String
    let desiredValue: String
    let actualValue: String
    let footer: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text("Desired")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.tertiary)
                Text(desiredValue)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Actual")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.tertiary)
                Text(actualValue)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }

            Text(footer)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct ExplanationTile: View {
    let eyebrow: String
    let title: String
    let headline: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(eyebrow)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Text(headline)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            Text(detail)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 190, alignment: .topLeading)
        .background(Color.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
