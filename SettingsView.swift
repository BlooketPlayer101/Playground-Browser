import SwiftUI

struct RealSettingsView: View {
    @AppStorage("showTabListInSidebar") var showTabsInSidebar = false
    @AppStorage("homePage") var homePageUrl = "https://google.com"
    @AppStorage("showHomepageField") var useCustomHomepage = false
    @AppStorage("useBeta") var showBetaFeatures = false
    
    var body: some View {
        NavigationStack {
            Form {
                Toggle(isOn: $showTabsInSidebar) {
                    Text("Show Tabs In Sidebar")
                }
                Toggle(isOn: $useCustomHomepage) {
                    Text("Use Custom New Tab URL")
                }
                Toggle(isOn: $showBetaFeatures) {
                    Text("Enable Unstable Features")
                }
                if useCustomHomepage {
                    Section("New Tab URL") {
                        TextField("https://google.com", text: $homePageUrl)
                    }
                }
            }
            .navigationTitle("Settings")
            .foregroundColor(.accentColor)
        }
        .cornerRadius(16)
        .shadow(radius: 20)
        .frame(width: 600, height: 500)
    }
}

struct SettingsPreview: PreviewProvider {
    static var previews: some View {
        RealSettingsView()
    }
}
