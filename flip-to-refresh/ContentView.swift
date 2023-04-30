//
//  ContentView.swift
//  flip-to-refresh
//
//  Created by Cristian Cretu on 30.04.2023.
//

import SwiftUI
import CoreMotion

struct Person {
    let imageName: String
    let name: String
    let username: String
    let post: String
    let id: Int
    let time: String
}

enum DeviceOrientation {
    case unknown, portrait, upsideDown
}

let people1 = [
    Person(imageName: "paco", name: "Paco Coursey", username: "paco", post: "spot the moment designers discovered mechanical keyboards", id: 1, time: "2s"),
    Person(imageName: "kelin", name: "kelin", username: "kelin", post: "i don’t care about the future of computing i just want to make people feel things", id: 2, time: "11m"),
    Person(imageName: "gavin", name: "gavin", username: "gavinnelson", post: "maybe it’s because I use GitHub all day, but my #1 request for all “improve writing” style GPT requests is to be able to easily see a diff comparing the input and output", id: 3, time: "21m"),
    Person(imageName: "joey", name: "Joey Banks", username: "joeyabanks", post: "'Dream in years. Plan in months. Evaluate in weeks. Ship daily.' -DJ Patil", id: 4, time: "36m"),
    Person(imageName: "shu", name: "shu", username: "shu", post: "With Next.js’ app directory and that new idea, it takes less than 150 lines of code to create this. ~4 lines are actually related to animation (wrapping the tree with <Satori>)", id: 5, time: "48m"),
]

let people2 = [
    Person(imageName: "josh", name: "Josh Miller", username: "joshm", post: "Lil' personal life update: 🇫🇷 I'm moving to Paris – for one year – starting in September! 🇫🇷", id: 6, time: "1s"),
    Person(imageName: "alex", name: "Alex Widua", username: "alexwidua", post: "I started with the idea of using a physical flip interaction to start/reset a timer and iterated from that", id: 7, time: "2m"),
    Person(imageName: "janum", name: "Janum Trivedi", username: "jmtrivedi", post: "- The values for each dot (translation, scale, spring response, etc.), are all keyed off of the touch’s distance - UIKit/Wave here, but made another in Metal for more “correct” deformation", id: 8, time: "6  m"),
    Person(imageName: "louis", name: "Lous Harboe", username: "spiralstairs", post: "here's a little one-handed search concept. field pinned to bottom + drag to dismiss. no more reaching 🙌🏼", id: 9, time: "4m"),
    Person(imageName: "john", name: "John Allen", username: "Jall_n", post: "The modern compass: designed for exploration, built for collaboration, AI as the foundation", id: 10, time: "8m"),
]


struct ContentView: View {
    @State private var lastKnownOrientation = DeviceOrientation.portrait

    let motionManager = CMMotionManager()
    @State private var firstArrayIsActive = true
    @State private var people = people1
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var offset: Double = -75
    @State private var blur: Double = 25


    var body: some View {
        VStack {
            ForEach(people, id: \.id) { person in
                HStack (alignment: .top, spacing: 16) {
                    Image(person.imageName)
                        .resizable()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())

                    VStack (alignment: .leading) {
                        HStack {
                            Text(person.name)
                                .font(.system(size: 16.0, weight: .bold, design: .rounded))

                            Text("@\(person.username)")
                                .opacity(0.5)
                                .font(.system(size: 16.0, weight: .medium, design: .rounded))


                            Text("\(person.time)")
                                .opacity(0.5)
                                .font(.system(size: 16.0, weight: .medium, design: .rounded))

                        }

                        Text(person.post)
                            .offset(y: 4)
                            .font(.system(size: 16.0, design: .rounded))

                    }
                }
                .padding()
                .background(.gray.opacity(0.20))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .frame(minWidth: 340, idealWidth: 340, maxWidth: 340, minHeight: 100, idealHeight: 100, maxHeight: 100)
                .scaleEffect(scale)
                .opacity(opacity)
                .offset(y: offset)
                .blur(radius: blur)
                .onAppear {
                    withAnimation(.spring().delay(Double(person.id%5 + 1) * 0.5)) {
                        scale = 1
                        opacity = 1
                        offset = 0
                        blur = 0
                    }
                }
            }
        }
        .onAppear {
            if motionManager.isDeviceMotionAvailable {
                motionManager.deviceMotionUpdateInterval = 0.02
                motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
                    if let data = data {
                        
                        self.handleDeviceMotionUpdate(data)
                    }
                }
            }
        }
        .onDisappear {
            motionManager.stopDeviceMotionUpdates()
        }
        .statusBarHidden(true)
    }

    func handleDeviceMotionUpdate(_ data: CMDeviceMotion) {

        let gravity = data.gravity
            let upsideDown = gravity.z > 0.8
            let portrait = gravity.z < -0.8

            if upsideDown {
                lastKnownOrientation = .upsideDown
            } else if portrait && lastKnownOrientation == .upsideDown {
                lastKnownOrientation = .portrait
                withAnimation {
                    withAnimation(.spring()) {
                        scale = 0
                        opacity = 0
                        offset = -75
                        blur = 25
                    }
                    self.people = firstArrayIsActive ? people2 : people1
                    firstArrayIsActive.toggle()
                    withAnimation(.spring()) {
                        scale = 1
                        opacity = 1
                        offset = 0
                        blur = 0
                    }
                }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
