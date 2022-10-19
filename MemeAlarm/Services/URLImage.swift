//
//  URLImage.swift
//  singleViewImageDownload
//
//  Created by Gabriel Davila on 28/8/21.
//

import SwiftUI

struct URLImage: View {
    
    //PinchToZoom variables
    @State var lastValue: CGFloat = 1.0
    @State var scale: CGFloat = 1.0
    @State var dragged: CGSize = .zero
    @State var prevDragged: CGSize = .zero
    @State var tapPoint: CGPoint = .zero
    @State var isTapped: Bool = false
    let maxScale: CGFloat = 4.0
    let minScale: CGFloat = 1.0
    
    //fullscreen variables
    let url: String
    let placeholder: String
    let allowPinchToZoom: Bool
    
    @ObservedObject var imageLoader = ImageLoader()
    
    init (url: String, placeholder: String = "loading", allowZoom: Bool) {
        
        self.url = Constants.imageHostURL + url
        self.placeholder = Constants.imageHostURL + placeholder
        self.allowPinchToZoom = allowZoom
        self.imageLoader.downloadImage(url: self.url)
        
    }
    
    var body: some View {
        
        let magnify = MagnificationGesture(minimumScaleDelta: 0.2)
            .onChanged { value in
                let resolvedDelta = value / self.lastValue
                self.lastValue = value
                let newScale = self.scale * resolvedDelta
                self.scale = min(self.maxScale, max(self.minScale, newScale))
                //print("\(min(self.maxScale, max(self.minScale, newScale)))")
                //print("delta=\(value) resolvedDelta=\(resolvedDelta)  newScale=\(newScale)")
            }
        
        let gestureDrag = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { (value) in
                self.tapPoint = value.startLocation
                self.dragged = CGSize(width: value.translation.width + self.prevDragged.width,
                                      height: value.translation.height + self.prevDragged.height)
                //print("dragged value = \(dragged)")
            }
        
        VStack {
            if let data = self.imageLoader.downloadedData {
                
                if allowPinchToZoom == true {
                    GeometryReader { geo in
                        Image(uiImage: UIImage(data: data)!)
                            .resizable()
                            .position(x: geo.size.width/2 ,y: geo.size.height/2)
                            .scaledToFit()
                            .animation(.default)
                            .offset(self.dragged)
                            .scaleEffect(self.scale)
                            .gesture(
                                TapGesture(count: 2).onEnded({
                                    self.isTapped.toggle()
                                    if self.scale > 1 {
                                        self.scale = 1
                                    } else {
                                        self.scale = 2
                                    }
                                    let parent = geo.frame(in: .local)
                                    self.postArranging(translation: CGSize.zero, in: parent)
                                })
                                .simultaneously(with: gestureDrag.onEnded({ (value) in
                                    let parent = geo.frame(in: .local)
                                    self.postArranging(translation: value.translation, in: parent)
                                }))
                            )
                            .gesture(magnify.onEnded { value in
                                // without this the next gesture will be broken
                                self.lastValue = 1.0
                                let parent = geo.frame(in: .local)
                                self.postArranging(translation: CGSize.zero, in: parent)
                            })
                            .onAppear {
                                self.scale = 1
                                let parent = geo.frame(in: .local)
                                self.postArranging(translation: CGSize.zero, in: parent)
                            }
                        
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    
                    
                }
                else {
                    Image(uiImage: UIImage(data: data)!)
                        .resizable()
                }
                
            } else {
                Image("loading").resizable()
            }
        }
    }
    
    private func postArranging(translation: CGSize, in parent: CGRect) {
        let scaled = self.scale
        let parentWidth = parent.maxX
        let parentHeight = parent.maxY
        let offset = CGSize(width: (parentWidth * scaled - parentWidth) / 1,
                            height: (parentHeight * scaled - parentHeight) / 1)

        //print("offset value - \(offset)")
        var resolved = CGSize()
        let newDraged = CGSize(width: self.dragged.width * scaled,
                               height: self.dragged.height * scaled)
        if newDraged.width > offset.width {
            resolved.width = offset.width / scaled
        } else if newDraged.width < -offset.width {
            resolved.width = -offset.width / scaled
        } else {
            resolved.width = translation.width + self.prevDragged.width
        }
        if newDraged.height > offset.height {
            resolved.height = offset.height / scaled
        } else if newDraged.height < -offset.height {
            resolved.height = -offset.height / scaled
        } else {
            resolved.height = translation.height + self.prevDragged.height
        }
        self.dragged = resolved
        self.prevDragged = resolved
    }
    
}

struct URLImage_Previews: PreviewProvider {
    static var previews: some View {
        URLImage(url: "https://gabelatin.github.io/learningapp-data/logo.png", allowZoom: true)
    }
}
