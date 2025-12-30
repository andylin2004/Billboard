//
//  BillboardTextView.swift
//  
//
//  Created by Hidde van der Ploeg on 01/07/2023.
//

import SwiftUI

struct BillboardTextView : View {
    let advert: BillboardAd
    
    var body: some View {
#if os(tvOS)
        VStack(alignment: .leading, spacing: 10) {
            BillboardAdInfoLabel(advert: advert)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(advert.title)
                    .font(.system(.title2, design: .rounded, weight: .heavy))
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(advert.description)
                    .font(.system(.body, design: .rounded))

                if let appStoreLink = advert.appStoreLink {
                    appStoreLink.qrCodeView
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                        .frame(width: 200, height: 200)
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0)
                        .padding(.top, 40)
                }

            }
        }
        .multilineTextAlignment(.leading)
        .foregroundColor(advert.text)
        .frame(maxWidth: 640)
        .padding(.horizontal, 24)
        .padding(.bottom, 64)
        #else
        VStack(spacing: 10) {
            BillboardAdInfoLabel(advert: advert)
            
            VStack(spacing: 6) {
                Text(advert.title)
                    .font(.system(.title2, design: .rounded, weight: .heavy))
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(advert.description)
                    .font(.system(.body, design: .rounded))
            }
        }
        .multilineTextAlignment(.center)
        .foregroundColor(advert.text)
        .frame(maxWidth: 640)
        .padding(.horizontal, 24)
        .padding(.bottom, 64)
#endif
    }
}

#Preview {
    BillboardTextView(advert: BillboardSamples.sampleDefaultAd)
}
