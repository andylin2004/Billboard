//
//  DefaultAdView.swift
//  
//
//  Created by Hidde van der Ploeg on 01/07/2023.
//

import SwiftUI

struct DefaultAdView : View {
    let advert : BillboardAd
    
    var body: some View {
        if #available(iOS 16, macOS 13, *) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    Spacer()
                    BillboardImageView(advert: advert)
                    
                    VStack {
                        Spacer()
                        BillboardTextView(advert: advert)
                        Spacer()
                    }
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    BillboardImageView(advert: advert)
                    BillboardTextView(advert: advert)
                    Spacer()
                }
                
            }
            .background(backgroundView)
        } else {
            VStack {
                Spacer()
                BillboardImageView(advert: advert)
                BillboardTextView(advert: advert)
                Spacer()
            }
            .background(backgroundView)
        }
    }
    
    
    @ViewBuilder
    var backgroundView : some View {
        if advert.transparent {
            CachedImage(url: advert.media.absoluteString, content: { phase in
                switch phase {
                case .success(let image):
                    ZStack {
                        advert.background
                            .ignoresSafeArea()
                        image
                            .resizable()
                            .opacity(0.1)
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 15)
                            .saturation(0.8)
                    }
                    
                    
                default:
                    Color(hex: advert.backgroundColor)
                        .ignoresSafeArea()
                }
            })
        }
    }
    
    
}

struct DefaultAdView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultAdView(advert: BillboardSamples.sampleDefaultAd)
    }
}

