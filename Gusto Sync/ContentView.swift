import SwiftUI
import UIKit

@available(iOS 16.0, *)
struct CalculatorItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
   
    var destinationView: some View {
        Group {
            switch name {
            case "Compress Image":
                CompressImageView()
            case "Precious Guardian":
                PreciousGuardian()
            case "Text To Speech":
                TextToSpeechView()
            default:
                EmptyView()
            }
        }
        .withAppBackground() // Apply consistent background to all views
    }
}

// MARK: - Main Content View
@available(iOS 16.0, *)
struct ContentView: View {
    let calculators: [CalculatorItem] = [
        CalculatorItem(name: "Compress Image", icon: "ruler"),
        CalculatorItem(name: "Precious Guardian", icon: "ruler"),
        CalculatorItem(name: "Text To Speech", icon: "thermometer")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background image
                Image("1")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.2)
                
                // Content
                VStack(spacing: 22) {
                    headerView
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            ForEach(calculators) { item in
                                NavigationLink {
                                    item.destinationView
                                        .navigationTitle(item.name)
                                        .navigationBarTitleDisplayMode(.inline)
                                } label: {
                                    CalculatorButtonView(item: item)
                                }
                            }
                        }
                        .padding(.top, 40)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 80)
                    }
                }
                .foregroundColor(.white)
            }
        }
        .navigationBarColor(backgroundColor: .brown, textColor: .orange)
    }

    private var headerView: some View {
        VStack(spacing: 6) {
            LinearGradient(colors: [.cyan, .blue, .purple],
                         startPoint: .leading, endPoint: .trailing)
                .mask(
                    Text("Gusto Sync")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                )
                .frame(height: 50)

            Text("")
                .font(.footnote)
                .foregroundColor(.indigo.opacity(0.85))
        }
        .padding(.top)
    }
}

// MARK: - Calculator Button View
@available(iOS 16.0, *)
struct CalculatorButtonView: View {
    let item: CalculatorItem
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.custom("times", size: 19).bold())
                    .foregroundColor(.teal)
                    .padding(.leading,120)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.black.opacity(0.9))
        }
        .frame(height:70)
        .padding(16)
        .background(
            ZStack {
                Image("q..")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.9)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Background Modifier
struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Image("1")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.2)
            
            content
        }
    }
}

extension View {
    func withAppBackground() -> some View {
        self.modifier(BackgroundModifier())
    }
    
    func navigationBarColor(backgroundColor: UIColor, textColor: UIColor) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, textColor: textColor))
    }
}

// MARK: - Navigation Bar Modifier
struct NavigationBarModifier: ViewModifier {
    var backgroundColor: UIColor
    var textColor: UIColor
    
    init(backgroundColor: UIColor, textColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: textColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: textColor]
        
        let backImage = UIImage(systemName: "chevron.left")?
            .withTintColor(textColor, renderingMode: .alwaysOriginal)
        
        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        appearance.backButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: textColor,
            .font: UIFont.systemFont(ofSize: 17)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = textColor
    }
    
    func body(content: Content) -> some View {
        content
    }
}

// MARK: - Previews
@available(iOS 16.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
