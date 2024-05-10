// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import WebKit
import Storage
import SwiftUI

class EditAddressViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        return webView
    }()

    var model: AddressListViewModel

    init(model: AddressListViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = webView
        setupWebView()
    }

    private func setupWebView() {
        model.saveAddressAction = { [weak self] in
        }

        model.toggleEditModeAction = { [weak self] isEditMode in
            self?.evaluateJavaScript("toggleEditMode(\(isEditMode));")
        }

        if let url = Bundle.main.url(forResource: "AddressManageForm", withExtension: "html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        webView.configuration.userContentController.add(self, name: "formData")
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        if message.name == "formData", let address = message.decodeBody(as: Address.self) {
//            print(address) // Consider more sophisticated error handling or UI update
//        }
    }

//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        injectJSONData(model.placeholders, withFunction: "localizePlaceholders")
//        let address = model.selectedAddress ?? model.addAddress ?? .empty
//        injectJSONData(address, withFunction: "fillAddressForm")
//    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let address = model.selectedAddress ?? model.addAddress ?? .empty
        injectJSONData(address, withFunction: "init")
    }

    private func injectJSONData<T: Encodable>(_ data: T, withFunction jsFunctionName: String) {
        do {
            let encoder = JSONEncoder()
            encoder.userInfo[.formatStyleKey] = FormatStyle.kebabCase
            let jsonData = try encoder.encode(data)
            guard let jsonString = String(
                data: jsonData,
                encoding: .utf8
            )?.replacingOccurrences(of: "\\", with: "\\\\") else { return }
            let jsCode = "\(jsFunctionName)(\(jsonString));"
            evaluateJavaScript(jsCode)
        } catch {
            print("Failed to encode data with error: \(error.localizedDescription)")
        }
    }

    private func evaluateJavaScript(_ jsCode: String) {
        webView.evaluateJavaScript(jsCode) { result, error in
            if let error = error {
                print("JavaScript execution error: \(error.localizedDescription)")
            }
        }
    }
}

struct EditAddressViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = EditAddressViewController

    var model: AddressListViewModel

    func makeUIViewController(context: Context) -> EditAddressViewController {
        let webViewController = EditAddressViewController(model: model)
        return webViewController
    }

    func updateUIViewController(_ uiViewController: EditAddressViewController, context: Context) {
        // Here you can update the view controller when your SwiftUI state changes.
        // Since the WebModel is passed at creation, there might not be much to do here.
    }
}
