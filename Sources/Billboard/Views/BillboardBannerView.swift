//
//  BillboardBannerView.swift
//
//  Created by Hidde van der Ploeg on 03/07/2023.
//

import SwiftUI

public struct BillboardBannerView : View {
    @Environment(\.accessibilityReduceMotion) private var reducedMotion
    @Environment(\.openURL) private var openURL
    
    let advert : BillboardAd
    let config : BillboardConfiguration
    let includeShadow : Bool
    let hideDismissButtonAndTimer : Bool
    
    @State private var canDismiss = false
    @State private var appIcon : NSUIImage? = nil
    @State private var showAdvertisement = true
    
    public init(advert: BillboardAd, config: BillboardConfiguration = BillboardConfiguration(), includeShadow: Bool = true, hideDismissButtonAndTimer: Bool = false) {
        self.advert = advert
        self.config = config
        self.includeShadow = includeShadow
        self.hideDismissButtonAndTimer = hideDismissButtonAndTimer
    }
    
    public var body: some View {
        
        ZStack(alignment: .trailing) {
            Button {
                if let url = advert.appStoreLink {
                    openURL(url)
                    canDismiss = true
                }
            } label: {
                HStack(spacing: 10) {
                    if let appIcon {
                        Image(nsuiImage: appIcon)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .accessibilityHidden(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        BillboardAdInfoLabel(advert: advert)
                        
                        VStack(alignment: .leading) {
                            Text(advert.title)
                                .font(.compatibleSystem(.footnote, design: .rounded, weight: .bold))
                                .foregroundColor(advert.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                            Text(advert.name)
                                .font(.compatibleSystem(.caption2, design: .rounded, weight: .medium).smallCaps())
                                .foregroundColor(advert.tint)
                                .opacity(0.8)
                        }
                    }
                    .accessibilityHidden(true)
                    Spacer()
                }
                .padding(.trailing, hideDismissButtonAndTimer ? 0: 40)
                .contentShape(Rectangle())
            }
            #if os(visionOS)
            .tint(advert.background.gradient)
            .shadow(color: includeShadow ? advert.background.opacity(0.5) : Color.clear, radius: 6, x: 0, y: 2)
            .contentShape(RoundedRectangle(cornerRadius: 16))
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 16))
            #else
            .buttonStyle(.plain)
            #endif
            #if os(visionOS)
            .frame(depth: 0)
            #endif
//            Spacer()
            
            Group {
                if !hideDismissButtonAndTimer {
                    if canDismiss {
                        Button {
                            #if os(iOS)
                            if config.allowHaptics {
                                haptics(.light)
                            }
                            #endif
                            showAdvertisement = false
                        } label: {
                            Label("Dismiss advertisement", systemImage: {
                                #if os(visionOS)
                                return "xmark"
                                #else
                                return "xmark.circle.fill"
                                #endif
                            }())
                                .labelStyle(.iconOnly)
                            #if os(macOS)
                                .font(.compatibleSystem(.title, design: .rounded, weight: .bold))
                            #else
                                .font(.compatibleSystem(.title2, design: .rounded, weight: .bold))
                            #endif
                                .symbolRenderingMode(.hierarchical)
                            #if !os(visionOS)
                                .imageScale(.large)
                                .controlSize(.large)
                            #endif
                        }
                        .tint(advert.tint)
                        #if os(visionOS)
                        .glassBackgroundEffect()
                        .foregroundColor(advert.tint)
                        #elseif os(macOS)
                        .buttonStyle(.borderless)
                        .foregroundColor(advert.tint)
                        #endif
                        
                    } else {
                        BillboardCountdownView(advert:advert,
                                               totalDuration: config.duration,
                                               canDismiss: $canDismiss)
                        .padding(.trailing, 2)
                    }
                }
            }
            .padding(.trailing, 9)
            #if os(visionOS)
            .frame(depth: 1)
            #endif
        }
        .accessibilityLabel(Text("\(advert.name), \(advert.title)"))
        #if !os(visionOS)
        .padding(10)
        .background(backgroundView)
        #endif
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.primary.opacity(0.1), lineWidth: 1))
        .animation(.spring(), value: showAdvertisement)
        .task {
            await fetchAppIcon()
        }
        .opacity(showAdvertisement ? 1 : 0)
        .scaleEffect(showAdvertisement ? 1 : 0)
        .frame(height: showAdvertisement ? nil : 0)
        .transaction {
            if reducedMotion { $0.animation = nil }
        }
        .onChange(of: advert) { _ in
            Task {
                await fetchAppIcon()
            }
        }
        
        
    }
    
    private func fetchAppIcon() async {
        if let data = try? await advert.getAppIcon() {
            await MainActor.run {
                appIcon = NSUIImage(data: data)
            }
        }
    }

    @ViewBuilder
    var backgroundView : some View {
        if #available(iOS 16.0, macOS 13, *) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(advert.background.gradient)
                .shadow(color: includeShadow ? advert.background.opacity(0.5) : Color.clear, radius: 6, x: 0, y: 2)
        } else {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(advert.background)
                .shadow(color: includeShadow ? advert.background.opacity(0.5) : Color.clear, radius: 6, x: 0, y: 2)
        }
    }
}


struct BillboardBannerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BillboardBannerView(advert: BillboardSamples.sampleDefaultAd)
            BillboardBannerView(advert: BillboardSamples.sampleDefaultAd, hideDismissButtonAndTimer: true)
        }
        .padding()
        
    }
}
