import Foundation
import UIKit
import ADBCore

@MainActor
final class ScreenViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var isRunning = false
    @Published var errorMessage = ""

    private let clientProvider: () -> ADBClient?
    private var refreshTask: Task<Void, Never>?

    init(clientProvider: @escaping () -> ADBClient?) {
        self.clientProvider = clientProvider
    }

    deinit {
        refreshTask?.cancel()
    }

    func start() {
        guard !isRunning else { return }

        isRunning = true
        errorMessage = ""

        refreshTask = Task {
            while !Task.isCancelled {
                await captureScreen()

                try? await Task.sleep(
                    nanoseconds: 500_000_000
                )
            }
        }
    }

    func stop() {
        refreshTask?.cancel()
        refreshTask = nil
        isRunning = false
    }

    func captureScreen() async {
        guard let client = clientProvider() else {
            errorMessage = "Not connected"
            return
        }

        do {
            let base64 = try await client.shell(
                "screencap -p | base64 -w 0"
            )

            let clean = base64
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let data = Data(base64Encoded: clean) else {
                errorMessage = "Invalid screenshot data"
                return
            }

            guard let decoded = UIImage(data: data) else {
                errorMessage = "Cannot decode screenshot"
                return
            }

            image = decoded
            errorMessage = ""

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func tap(x: Int, y: Int) {
        runShell("input tap \(x) \(y)")
    }

    func swipe(
        x1: Int,
        y1: Int,
        x2: Int,
        y2: Int,
        duration: Int = 300
    ) {
        runShell(
            "input swipe \(x1) \(y1) \(x2) \(y2) \(duration)"
        )
    }

    func power() {
        runShell("input keyevent 26")
    }

    func home() {
        runShell("input keyevent 3")
    }

    func back() {
        runShell("input keyevent 4")
    }

    func recentApps() {
        runShell("input keyevent 187")
    }

    private func runShell(_ command: String) {
        guard let client = clientProvider() else {
            errorMessage = "Not connected"
            return
        }

        Task {
            do {
                _ = try await client.shell(command)
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
