```swift
import SwiftUI
import UIKit

struct ScreenView: View {
    @ObservedObject var vm: ScreenViewModel

    var body: some View {
        VStack(spacing: 12) {

            HStack {
                Text("Screen")
                    .font(.headline)

                Spacer()

                if vm.isRunning {
                    Button("Stop") {
                        vm.stop()
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button("Start") {
                        vm.start()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            if let image = vm.image {
                GeometryReader { geometry in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            maxWidth: geometry.size.width,
                            maxHeight: geometry.size.height
                        )
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 5)
                                .onEnded { value in
                                    handleGesture(
                                        value,
                                        size: geometry.size,
                                        image: image
                                    )
                                }
                        )
                        .onTapGesture { location in
                            handleTap(
                                location,
                                size: geometry.size,
                                image: image
                            )
                        }
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black)

                    Text("No screen")
                        .foregroundStyle(.white)
                }
                .frame(minHeight: 300)
            }

            if !vm.errorMessage.isEmpty {
                Text(vm.errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            HStack(spacing: 10) {
                Button("Back") {
                    vm.back()
                }

                Button("Home") {
                    vm.home()
                }

                Button("Recent") {
                    vm.recentApps()
                }

                Button("Power") {
                    vm.power()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("Screen")
        .onDisappear {
            vm.stop()
        }
    }

    private func handleTap(
        _ location: CGPoint,
        size: CGSize,
        image: UIImage
    ) {
        let imageSize = image.size

        guard imageSize.width > 0, imageSize.height > 0 else {
            return
        }

        let scale = min(
            size.width / imageSize.width,
            size.height / imageSize.height
        )

        let displayedWidth = imageSize.width * scale
        let displayedHeight = imageSize.height * scale

        let offsetX = (size.width - displayedWidth) / 2
        let offsetY = (size.height - displayedHeight) / 2

        let x = Int(
            ((location.x - offsetX) / scale)
                .clamped(to: 0...imageSize.width)
        )

        let y = Int(
            ((location.y - offsetY) / scale)
                .clamped(to: 0...imageSize.height)
        )

        vm.tap(x: x, y: y)
    }

    private func handleGesture(
        _ value: DragGesture.Value,
        size: CGSize,
        image: UIImage
    ) {
        let start = value.startLocation
        let end = value.location

        let imageSize = image.size

        guard imageSize.width > 0, imageSize.height > 0 else {
            return
        }

        let scale = min(
            size.width / imageSize.width,
            size.height / imageSize.height
        )

        let displayedWidth = imageSize.width * scale
        let displayedHeight = imageSize.height * scale

        let offsetX = (size.width - displayedWidth) / 2
        let offsetY = (size.height - displayedHeight) / 2

        func convert(_ point: CGPoint) -> (Int, Int) {
            let x = Int(
                ((point.x - offsetX) / scale)
                    .clamped(to: 0...imageSize.width)
            )

            let y = Int(
                ((point.y - offsetY) / scale)
                    .clamped(to: 0...imageSize.height)
            )

            return (x, y)
        }

        let p1 = convert(start)
        let p2 = convert(end)

        vm.swipe(
            x1: p1.0,
            y1: p1.1,
            x2: p2.0,
            y2: p2.1
        )
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
```
