
import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ADBViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    connectionSection
                
                    deviceSection
                
                    if vm.isConnected {
                        NavigationLink {
                            ScreenView(
                                vm: ScreenViewModel {
                                    vm.client
                                }
                            )
                        } label: {
                            Label("Screen", systemImage: "iphone")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                
                    terminalSection
                }
                .padding()
            }
            .navigationTitle("iADB")
        }
    }

    private var connectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ADB connection")
                .font(.headline)

            HStack {
                TextField("Host", text: $vm.host)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                TextField("Port", text: $vm.port)
                    .keyboardType(.numberPad)
                    .frame(width: 90)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Circle()
                    .fill(vm.isConnected ? .green : .red)
                    .frame(width: 10, height: 10)

                Text(vm.status)
                    .font(.subheadline)

                Spacer()

                if vm.isConnected {
                    Button("Disconnect") {
                        vm.disconnect()
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button(vm.isBusy ? "Connecting..." : "Connect") {
                        vm.connect()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isBusy)
                }
            }
        }
    }

    private var deviceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Device")
                .font(.headline)

            infoRow("Model", vm.model)
            infoRow("Android", vm.androidVersion)
            infoRow("SDK", vm.sdkVersion)
            infoRow("Battery", vm.battery)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var terminalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Shell")
                    .font(.headline)

                Spacer()

                Button("Clear") {
                    vm.clearOutput()
                }
            }

            ScrollView {
                Text(vm.output.isEmpty ? "ADB shell output..." : vm.output)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .padding()
            }
            .frame(minHeight: 300)
            .background(Color.black.opacity(0.9))
            .foregroundStyle(.green)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            HStack {
                TextField("adb shell command", text: $vm.command)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(.body, design: .monospaced))
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        vm.executeCommand()
                    }

                Button("Run") {
                    vm.executeCommand()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.isConnected)
            }
        }
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.system(.body, design: .monospaced))
        }
    }
}
