// Photos are from https://unsplash.com

import SwiftUI

struct TransitionIsActiveKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var transitionIsActive: Bool {
        get { self[TransitionIsActiveKey.self] }
        set { self[TransitionIsActiveKey.self] = newValue }
    }
}

struct TransitionReader<Content: View>: View {
    var content: (Bool) -> Content
    @Environment(\.transitionIsActive) var active
    
    var body: some View {
        content(active)
    }
}

struct TransitionActive: ViewModifier {
    var active: Bool
    
    func body(content: Content) -> some View {
        content
            .environment(\.transitionIsActive, active)
    }
}

struct PhotosView: View {
    @State private var detail: Int? = nil
    @State private var slowAnimations = false
    @Namespace private var namespace
    @Namespace private var dummyNS
    
    
    var body: some View {
        VStack {
            Toggle("Slow Animations", isOn: $slowAnimations)
            ZStack {
                photoGrid
                    .opacity(detail == nil ? 1 : 0)
                detailView
            }
            .animation(.default.speed(slowAnimations ? 0.2 : 1), value: detail)
        }
    }
    
    @ViewBuilder
    var detailView: some View {
        if let d = detail {
            ZStack {
                TransitionReader { active in
                    Image("beach_\(d)")
                        .resizable()
                        .mask {
                            Rectangle().aspectRatio(1, contentMode: active ? .fit : .fill)
                        }
                        .matchedGeometryEffect(id: d, in: active ? namespace : dummyNS, isSource: false)
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            detail = nil
                        }
                }
            }
            .zIndex(2)
            .id(d)
            .transition(.modifier(active: TransitionActive(active: true), identity: TransitionActive(active: false)))
        }
    }
    
    var photoGrid: some View {
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 100, maximum: .infinity), spacing: 3)], spacing: 3) {
                ForEach(1..<11) { ix in
                    Image("beach_\(ix)")
                        .resizable()
                        .matchedGeometryEffect(id: ix, in: namespace)
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipped()
                        .aspectRatio(1, contentMode: .fit)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            detail = ix
                        }
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        PhotosView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
