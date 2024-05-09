// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI
import Common
import Shared
import Storage
import WebKit

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

    // MARK: - Body

    var body: some View {
        List {
            if viewModel.showSection {
                Section(header: Text(String.Addresses.Settings.SavedAddressesSectionTitle)) {
                    ForEach(viewModel.addresses, id: \.self) { address in
                        AddressCellView(
                            windowUUID: windowUUID,
                            address: address,
                            onTap: { viewModel.selectedAddress = address }
                        )
                    }
                }
                .font(.caption)
                .foregroundColor(customLightGray)
            }
        }
        .listStyle(.plain)
        .listRowInsets(EdgeInsets())
        .sheet(item: $viewModel.selectedAddress) { address in
            NavigationView {
                EditAddressViewControllerRepresentable(model: viewModel)
                    .navigationBarTitle(String.Addresses.Settings.EditAddressTitle, displayMode: .inline)
                    .toolbar {
                        ToolbarItemGroup(placement: .cancellationAction) {
                            if viewModel.isEditMode {
                                Button(String.Addresses.Settings.CancelNavBarButtonLabel) {
                                    viewModel.toggleEditMode()
                                }
                            } else {
                                Button(String.Addresses.Settings.CloseNavBarButtonLabel) {
                                    viewModel.selectedAddress = nil
                                }
                            }
                        }

                        ToolbarItemGroup(placement: .primaryAction) {
                            if viewModel.isEditMode {
                                Button(String.Addresses.Settings.SaveNavBarButtonLabel) {
                                    viewModel.saveAddress { _ in }
                                    viewModel.toggleEditMode()
                                }
                            } else {
                                Button(String.Addresses.Settings.EditNavBarButtonLabel) {
                                    viewModel.toggleEditMode()
                                }
                            }
                        }
                    }
            }
        }
        .sheet(item: $viewModel.addAddress) { address in
            NavigationView {
                EditAddressViewControllerRepresentable(model: viewModel)
                    .navigationBarTitle(String.Addresses.Settings.AddAddressTitle, displayMode: .inline)
                    .navigationBarItems(
                        leading: Button(String.Addresses.Settings.CloseNavBarButtonLabel) {
                            viewModel.addAddress = nil
                        },
                        trailing: Button(String.Addresses.Settings.SaveNavBarButtonLabel) {
                            viewModel.saveAddress(completion: { _ in })
                        }
                    )
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
