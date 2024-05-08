// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI
import Common
import Shared
import Storage
import WebKit

// TODO: Clean this up. This is just for testing purposes.
// Super hacky
func addressToDict(address: Address) -> [String: Any] {
    var dictionary: [String: Any] = [:]

    dictionary["address-level1"] = address.addressLevel1 ?? ""
    dictionary["address-level2"] = address.addressLevel2 ?? ""
    dictionary["address-level3"] = address.addressLevel3 ?? ""
    dictionary["country"] = address.country ?? ""
    dictionary["email"] = address.email ?? ""
    dictionary["name"] = address.name ?? ""
    dictionary["organization"] = address.organization ?? ""
    dictionary["postal-code"] = address.postalCode ?? ""
    dictionary["street-address"] = address.streetAddress ?? ""
    dictionary["tel"] = address.tel ?? ""
    
    return dictionary
}

struct WebView: UIViewRepresentable {
    let address: [String: Any]
    @Binding var webView: WKWebView?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        self._webView.wrappedValue = webView
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let url = Bundle.main.url(forResource: "AddressManageForm", withExtension: "html")!
        // TODO: Let's put everything in a subdir so we don't give access to any files
        // We don't need to.
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func makeCoordinator() -> WebViewCoordinator {
        return WebViewCoordinator(data: address)
    }

    class WebViewCoordinator: NSObject, WKNavigationDelegate {
            let data: [String: Any]

            init(data: [String: Any]) {
                self.data = data
            }

            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [])
                guard let jsonString = String(data: jsonData!, encoding: .utf8) else { return }

                let script = """
                init(\(jsonString));
                """

                webView.evaluateJavaScript(script) { result, error in
                    if let error = error {
                        print("JavaScript Injection Error: \(error.localizedDescription)")
                    }
                }
            }
        }
}

class AddressManager: ObservableObject {
    @Published var selectedAddress: [String: Any]?
    @Published var showWebView = false
}

struct WebViewWithControls: View {
    @Environment(\.presentationMode) var presentationMode
    var address: [String: Any]
    @Binding var webView: WKWebView?
    init(address: [String: Any], webView: Binding<WKWebView?>) {
            self.address = address
            self._webView = webView
    }

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                Button("Edit") {
                    guard let webView = webView else {
                                print("WebView is not available")
                                return
                    }
                    let script = "toggleEditMode()"
                    webView.evaluateJavaScript(script) { result, error in
                        if let error = error {
                            print("JavaScript Injection Error: \(error)")
                        }
                    }

                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))

        WebView(address: address,  webView: $webView)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}

// MARK: - AddressListView

/// A view displaying a list of addresses.
struct AddressListView: View {
    // MARK: - Properties

    let windowUUID: WindowUUID
    @Environment(\.themeManager)
    var themeManager
    @ObservedObject var viewModel: AddressListViewModel
    @State private var customLightGray: Color = .clear
    @State private var webView: WKWebView?
    @ObservedObject var addressManager = AddressManager()
    
    // MARK: - Body

    var body: some View {
        List {
            if viewModel.showSection {
                Section(header: Text(String.Addresses.Settings.SavedAddressesSectionTitle)) {
                    ForEach(viewModel.addresses, id: \.self) { address in
                        AddressCellView(
                            windowUUID: windowUUID,
                            address: address,
                            onTap: {
                                // TODO: PHASE - 2: FXIOS-7653 Handle action when address cell is tapped.
                                addressManager.selectedAddress = addressToDict(address: address)
                                addressManager.showWebView = true
                                
                            }
                        )
                    }
                }
                .font(.caption)
                .foregroundColor(customLightGray)
            }
        }
        .listStyle(.plain)
        .listRowInsets(EdgeInsets())
        .sheet(isPresented: $addressManager.showWebView) {
            if let address = addressManager.selectedAddress {
                WebViewWithControls(address: address, webView: $webView)
            } else {
                Text("No address selected.")
            }
        }
        .onAppear {
            viewModel.fetchAddresses()
            applyTheme(theme: themeManager.currentTheme(for: windowUUID))
        }
        .onReceive(NotificationCenter.default.publisher(for: .ThemeDidChange)) { notification in
            guard let uuid = notification.object as? UUID, uuid == windowUUID else { return }
            applyTheme(theme: themeManager.currentTheme(for: windowUUID))
        }
    }

    // MARK: - Theme Application

    /// Applies the theme to the view.
    /// - Parameter theme: The theme to be applied.
    func applyTheme(theme: Theme) {
        let color = theme.colors
        customLightGray = Color(color.textSecondary)
    }
}
