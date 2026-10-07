
import Foundation
import ADBCore

@MainActor
final class ADBViewModel: ObservableObject {
    @Published var host: String {
        didSet {
            UserDefaults.standard.set(host, forKey: "adb.host")
        }
    }

    @Published var port: String {
        didSet {
            UserDefaults.standard.set(port, forKey: "adb.port")
        }
    }

    @Published var command = ""
    @Published var output = ""
    @Published var status = "Disconnected"
    @Published var isConnected = false
    @Published var isBusy = false

    @Published var model = "-"
    @Published var androidVersion = "-"
    @Published var sdkVersion = "-"
    @Published var battery = "-"

    var client: ADBClient?

    init() {
        host = UserDefaults.standard.string(forKey: "adb.host") ?? "100.100.10.1"
        port = UserDefaults.standard.string(forKey: "adb.port") ?? "5555"
    }

    func connect() {
        guard !isBusy else { return }

        guard let portNumber = UInt16(port) else {
            status = "Invalid port"
            return
        }

        isBusy = true
        status = "Connecting..."

        Task {
            do {
                let adb = try ADBClient()

                try await adb.connect(
                    host: host,
                    port: portNumber
                )

                client = adb
                isConnected = true
                status = "Connected"

                await loadDeviceInfo()

            } catch {
                client = nil
                isConnected = false
                status = "Error: \(error.localizedDescription)"
            }

            isBusy = false
        }
    }

    func disconnect() {
        guard let client else {
            isConnected = false
            status = "Disconnected"
            return
        }

        Task {
            await client.disconnect()
            self.client = nil
            self.isConnected = false
            self.status = "Disconnected"
        }
    }

    func executeCommand() {
        guard let client else {
            output += "\nNot connected.\n"
            return
        }

        let commandToRun = command.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !commandToRun.isEmpty else {
            return
        }

        command = ""
        output += "$ \(commandToRun)\n"

        Task {
            do {
                let result = try await client.shell(commandToRun)

                if !result.isEmpty {
                    output += result + "\n"
                }
            } catch {
                output += "ERROR: \(error.localizedDescription)\n"
            }

            output += "\n"
        }
    }

    func clearOutput() {
        output = ""
    }

    private func loadDeviceInfo() async {
        guard let client else {
            return
        }

        do {
            model = try await client.getDeviceProperty("ro.product.model")
        } catch {
            model = "?"
        }

        do {
            androidVersion = try await client.getAndroidVersion()
        } catch {
            androidVersion = "?"
        }

        do {
            sdkVersion = try await client.getSDKVersion()
        } catch {
            sdkVersion = "?"
        }

        do {
            battery = try await client.getBatteryLevel()
        } catch {
            battery = "?"
        }
    }
}
