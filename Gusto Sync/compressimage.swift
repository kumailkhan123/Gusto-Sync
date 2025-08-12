import SwiftUI
import UIKit
import PhotosUI

@available(iOS 16.0, *)
struct CompressImageView: View {
    @State private var selectedImage: UIImage?
    @State private var compressedImage: UIImage?
    @State private var originalImageSize: Double = 0
    
    @State private var compressionRatio: Float = 0.5
    @State private var isCompressing = false
    
    @State private var imageHistory: [(image: UIImage, compression: Float)] = []
    @State private var showHistory = false
    
    @State private var showModal = false
    @State private var modalMessage = ""
    @State private var modalTitle = ""
    @State private var modalIcon = ""
    @State private var modalColor: Color = .blue
    @State private var showImagePicker = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var bounce = false
    @State private var rotate = false
    @State private var showWelcome = true
    
    // Modern color palette
    private let primaryColor = Color(red: 0.58, green: 0.42, blue: 0.94) // Neon purple
    private let secondaryColor = Color(red: 0.41, green: 0.84, blue: 0.91) // Electric teal
    private let accentColor = Color(red: 0.99, green: 0.44, blue: 0.44) // Coral pink
    private let darkColor = Color(red: 0.08, green: 0.08, blue: 0.12) // Deep space
    
    // Glass morphism effect
    private let glassEffect = Material.ultraThinMaterial
    
    var body: some View {
        NavigationView {
            ZStack {
                // Cosmic background
                AnimatedCosmicBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        HeaderSection()
                        
                        // Image preview with floating card effect
                        ImageDisplaySection()
                            .modifier(FloatingCardModifier())
                        
                        // Compression controls with glass effect
                        CompressionControlsSection()
                            .background(glassEffect)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .modifier(FloatingCardModifier())
                        
                        // Action buttons with holographic effect
                        ActionButtonsSection()
                            .background(glassEffect)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .modifier(FloatingCardModifier())
                        
                        // History section with timeline effect
                        if showHistory && !imageHistory.isEmpty {
                            ImageHistorySection()
                                .modifier(FloatingCardModifier())
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                }
                
                // Welcome overlay with particle effect
                if showWelcome {
                    WelcomeOverlay()
                }
                
                // Modern alert system
                if showModal {
                    ModernAlertView(
                        icon: modalIcon,
                        title: modalTitle,
                        message: modalMessage,
                        color: modalColor,
                        dismissAction: { showModal = false }
                    )
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(onPick: handleImageSelection, onCancel: {
                    showImagePicker = false
                })
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityViewController(activityItems: shareItems)
            }
        }
        .accentColor(primaryColor)
       
        
    }
    
    // MARK: - Custom Components
    
    private struct AnimatedCosmicBackground: View {
        @State private var particleOffset = CGSize.zero
        
        var body: some View {
            ZStack {
                // Deep space gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.2, green: 0.2, blue: 0.1), Color(red: 0.1, green: 0.5, blue: 0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                // Floating particles
                ForEach(0..<30) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.05...0.2)))
                        .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3...8))
                                .repeatForever(autoreverses: true),
                            value: particleOffset
                        )
                }
            }
            .onAppear {
                particleOffset = CGSize(width: CGFloat.random(in: -50...50), height: CGFloat.random(in: -50...50))
            }
        }
    }
    
    private struct FloatingCardModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground).opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [.white.opacity(0.2), .clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing),
                            lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        )}
    }
    @available(iOS 16.0, *)
    private struct ModernAlertView: View {
        var icon: String
        var title: String
        var message: String
        var color: Color
        var dismissAction: () -> Void
        
        @State private var animate = false
        @State private var sparkle = false
        
        var body: some View {
            ZStack {
                // Background blur
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { dismissAction() }
                
                // Alert container
                VStack(spacing: 16) {
                    // Animated icon
                    ZStack {
                        // Pulsing halo effect
                        Circle()
                            .fill(color.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .scaleEffect(animate ? 1.2 : 0.8)
                            .opacity(animate ? 0 : 0.6)
                        
                        // Main icon
                        if #available(iOS 17.0, *) {
                            Image(systemName: icon)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(color)
                                .symbolEffect(.bounce, value: animate)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    .padding(.top, 20)
                    
                    // Text content
                    VStack(spacing: 8) {
                        Text(title)
                            .font(.title2.bold())
                            .foregroundColor(color)
                            .textCase(.uppercase)
                            .tracking(1)
                        
                        Text(message)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Dismiss button
                    Button(action: dismissAction) {
                        Text("GOT IT")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(color.gradient)
                                    .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.bottom, 20)
                }
                .frame(width: 280)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(.systemBackground))
                        .shadow(color: color.opacity(0.2), radius: 20, x: 0, y: 10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
                .scaleEffect(animate ? 1.0 : 0.8)
                .opacity(animate ? 1.0 : 0.0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                    animate = true
                }
            }
        }
    }
    
    // MARK: - Header Section
    private func HeaderSection() -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("IMAGE OPTIMIZER")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundLinearGradient(
                            colors: [primaryColor, secondaryColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    
                    Text("Reduce file size without losing quality")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Floating action button
                Button(action: { showImagePicker = true }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(14)
                        .background(
                            Circle()
                                .fill(primaryColor.gradient)
                                .shadow(color: primaryColor.opacity(0.6), radius: 8, x: 0, y: 4)
                        )
                }
            }
            .padding(.horizontal, 16)
            
            // Animated divider
            Capsule()
                .frame(height: 2)
                .foregroundLinearGradient(
                    colors: [primaryColor.opacity(0.5), secondaryColor.opacity(0.5), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
        }
    }
    
    // MARK: - Image Display Section
    private func ImageDisplaySection() -> some View {
        VStack(spacing: 16) {
            if let image = activeImage {
                // Image preview with holographic effect
                VStack(spacing: 20) {
                    // Floating image with reflection
                    VStack(spacing: 0) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(LinearGradient(
                                        gradient: Gradient(colors: [primaryColor.opacity(0.8), secondaryColor.opacity(0.8)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing),
                                        lineWidth: 2)
                            )
                            .shadow(color: primaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.bottom, 4)
                        
                        // Reflection effect
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .opacity(0.2)
                            .rotationEffect(.degrees(180))
                            .offset(y: -8)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black, .clear]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(height: 40)
                            )
                    }
                    
                    // Stats with animated indicators
                    HStack(spacing: 16) {
                        StatBadge(
                            title: "ORIGINAL",
                            value: "\(selectedImage?.sizeInKB ?? 0) KB",
                            icon: "photo",
                            color: .gray
                        )
                        
                        StatBadge(
                            title: "COMPRESSED",
                            value: "\(image.sizeInKB) KB",
                            icon: "arrow.down",
                            color: secondaryColor
                        )
                        
                        StatBadge(
                            title: "SAVINGS",
                            value: "\(Int((1.0 - compressionRatio) * 100))%",
                            icon: "percent",
                            color: primaryColor
                        )
                    }
                    .padding(.horizontal, 16)
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))
            } else {
                // Empty state with animated placeholder
                VStack(spacing: 20) {
                    if #available(iOS 17.0, *) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .symbolEffect(.pulse)
                            .foregroundColor(primaryColor.opacity(0.5))
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    Text("NO IMAGE SELECTED")
                        .font(.headline)
                        .foregroundColor(.white)
                        .tracking(1)
                    
                    Button(action: { showImagePicker = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("SELECT IMAGE")
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryColor, secondaryColor]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: primaryColor.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(30)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            style: StrokeStyle(
                                lineWidth: 2,
                                dash: [8],
                                dashPhase: bounce ? 16 : 0
                            )
                        )
                        .foregroundColor(secondaryColor.opacity(0.3))
                )
                .onAppear {
                    withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                        bounce.toggle()
                    }
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Compression Controls Section
    private func CompressionControlsSection() -> some View {
        VStack(spacing: 20) {
            HStack {
                Text("COMPRESSION SETTINGS")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(1)
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Interactive slider with dynamic color
                VStack(spacing: 8) {
                    HStack {
                        Text("QUALITY LEVEL")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(Int(compressionRatio * 100))%")
                            .font(.subheadline.bold())
                            .foregroundColor(
                                compressionRatio > 0.7 ? .green :
                                compressionRatio > 0.4 ? .yellow :
                                .red
                            )
                    }
                    
                    CustomSlider(
                        value: $compressionRatio,
                        range: 0.1...1.0,
                        thumbColor: primaryColor,
                        minTrackGradient: Gradient(colors: [.red, .orange, .green]),
                        maxTrackColor: Color.gray.opacity(0.3)
                    )
                    
                    HStack {
                        Text("SMALLER FILE")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text("BETTER QUALITY")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                // Animated compress button
                Button(action: compressImage) {
                    HStack {
                        if isCompressing {
                            ProgressView()
                                .tint(.white)
                            Text("OPTIMIZING...")
                        } else {
                            Image(systemName: "sparkles")
                            Text("OPTIMIZE IMAGE")
                        }
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [primaryColor, secondaryColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .shadow(color: primaryColor.opacity(0.5), radius: 10, x: 0, y: 5)
                    )
                    .cornerRadius(12)
                    .scaleEffect(bounce ? 1.02 : 1.0)
                }
                .disabled(isCompressing || selectedImage == nil)
                .opacity((isCompressing || selectedImage == nil) ? 0.6 : 1.0)
            }
            .padding()
        }
    }
    
    // MARK: - Action Buttons Section
    private func ActionButtonsSection() -> some View {
        VStack(spacing: 16) {
            if activeImage != nil {
                HStack {
                    Text("ACTIONS")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1)
                    Spacer()
                    
                    if !imageHistory.isEmpty {
                        Button(action: toggleHistory) {
                            HStack(spacing: 4) {
                                Image(systemName: showHistory ? "clock.fill" : "clock")
                                Text(showHistory ? "HIDE HISTORY" : "SHOW HISTORY")
                            }
                            .font(.caption.bold())
                            .foregroundColor(secondaryColor)
                            .padding(6)
                            .padding(.horizontal, 8)
                            .background(secondaryColor.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                }
                
                // Hexagonal grid of action buttons
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ActionButton1(
                        icon: "arrow.clockwise",
                        label: "RESET",
                        color: .gray,
                        action: { compressedImage = nil }
                    )
                    
                    ActionButton1(
                        icon: "square.and.arrow.up",
                        label: "SHARE",
                        color: .green,
                        action: { shareImage() }
                    )
                    
                    ActionButton1(
                        icon: "square.and.arrow.down",
                        label: "SAVE",
                        color: accentColor,
                        action: { saveImage() }
                    )
                    
                    ActionButton1(
                        icon: "doc.on.doc",
                        label: "COPY",
                        color: .purple,
                        action: { copyImage() }
                    )
                    
                    ActionButton1(
                        icon: "trash",
                        label: "CLEAR",
                        color: .pink,
                        action: { clearImage() }
                    )
                    
                    if !imageHistory.isEmpty {
                        ActionButton(
                            icon: "clock.arrow.circlepath",
                            label: "HISTORY",
                            color: .teal,
                            action: { toggleHistory() }
                        )
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Image History Section
    private func ImageHistorySection() -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("OPTIMIZATION HISTORY")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(1)
                Spacer()
                
                if !imageHistory.isEmpty {
                    Button(action: clearHistory) {
                        Image(systemName: "trash")
                            .foregroundColor(.pink)
                            .padding(6)
                            .background(Circle().fill(Color.pink.opacity(0.2)))
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(imageHistory.indices.reversed(), id: \.self) { index in
                        HistoryItemView(
                            item: imageHistory[index],
                            index: index,
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor,
                            restoreAction: restoreFromHistory,
                            copyAction: copyImage,
                            saveAction: saveImage,
                            shareAction: shareImage,
                            removeAction: removeFromHistory
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
    }
    
    // MARK: - Welcome Overlay
    private func WelcomeOverlay() -> some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.9)
                .edgesIgnoringSafeArea(.all)
            
            // Particle effect
            ForEach(0..<15) { i in
                Circle()
                    .fill([primaryColor, secondaryColor, accentColor].randomElement()!)
                    .frame(width: CGFloat.random(in: 2...6), height: CGFloat.random(in: 2...6))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(0.6)
                    .blur(radius: 2)
            }
            
            VStack(spacing: 24) {
                // Animated icon
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    if #available(iOS 17.0, *) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .symbolEffect(.variableColor.iterative, options: .repeating)
                            .foregroundLinearGradient(colors: [primaryColor, secondaryColor])
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                VStack(spacing: 12) {
                    Text("WELCOME TO IMAGE OPTIMIZER")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .tracking(1)
                    
                    Text("Reduce image sizes with precision control while maintaining visual quality. Perfect for social media, websites, and storage optimization.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showWelcome = false
                    }
                }) {
                    Text("GET STARTED")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.white.opacity(0.2), .clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .shadow(color: primaryColor.opacity(0.5), radius: 10, x: 0, y: 5)
                        )
                        .cornerRadius(12)
                        .scaleEffect(bounce ? 1.05 : 1.0)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(darkColor)
                    .shadow(color: primaryColor.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(40)
        }
    }
    
    // MARK: - Helper Properties
    private var activeImage: UIImage? {
        compressedImage ?? selectedImage
    }
    
    // MARK: - Helper Methods
    private func handleImageSelection(_ image: UIImage) {
        selectedImage = image
        originalImageSize = Double(image.sizeInKB)
        compressedImage = nil
        animateSelection()
    }
    
    private func animateSelection() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
            bounce = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            bounce = false
        }
    }
    
    private func compressImage() {
        guard let image = selectedImage else {
            showMessage("Please select an image first!",
                       title: "No Image Selected",
                       icon: "exclamationmark.triangle.fill",
                       color: .orange)
            return
        }
        
        isCompressing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let imageData = image.jpegData(compressionQuality: CGFloat(compressionRatio)) else {
                DispatchQueue.main.async {
                    isCompressing = false
                    showMessage("Failed to compress image.",
                               title: "Compression Failed",
                               icon: "xmark.octagon.fill",
                               color: .red)
                }
                return
            }
            
            let compressedImage = UIImage(data: imageData)
            
            DispatchQueue.main.async {
                self.compressedImage = compressedImage
                
                if let compressedImage = compressedImage {
                    addToHistory(image: compressedImage)
                    showSuccessMessage()
                    animateSelection()
                }
                
                isCompressing = false
            }
        }
    }
    
    private func addToHistory(image: UIImage) {
        if imageHistory.last?.image != image || imageHistory.isEmpty {
            withAnimation {
                imageHistory.append((image: image, compression: compressionRatio))
            }
        }
    }
    
    private func showSuccessMessage() {
        showMessage("Image optimized to \(Int(compressionRatio * 100))% quality",
                    title: "Optimization Complete",
                    icon: "checkmark.circle.fill",
                    color: primaryColor)
    }
    
    private func clearImage() {
        withAnimation(.spring()) {
            selectedImage = nil
            compressedImage = nil
        }
        showMessage("Image cleared from workspace",
                    title: "Workspace Cleared",
                    icon: "trash.fill",
                    color: .red)
    }
    
    private func copyImage(image: UIImage? = nil) {
        let imageToCopy = image ?? activeImage
        guard let img = imageToCopy else {
            showMessage("No image to copy!",
                       title: "Error",
                       icon: "exclamationmark.triangle.fill",
                       color: .orange)
            return
        }
        UIPasteboard.general.image = img
        showMessage("Image copied to clipboard",
                   title: "Copied",
                   icon: "doc.on.clipboard.fill",
                   color: .purple)
    }
    
    private func saveImage(image: UIImage? = nil) {
        let imageToSave = image ?? activeImage
        guard let img = imageToSave else {
            showMessage("No image to save!",
                       title: "Error",
                       icon: "exclamationmark.triangle.fill",
                       color: .orange)
            return
        }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        showMessage("Image saved to Photos library",
                   title: "Saved",
                   icon: "heart.fill",
                   color: .pink)
    }
    
    private func shareImage(image: UIImage? = nil) {
        let imageToShare = image ?? activeImage
        guard let img = imageToShare else {
            showMessage("No image to share!",
                       title: "Error",
                       icon: "exclamationmark.triangle.fill",
                       color: .orange)
            return
        }
        shareItems = [img]
        showShareSheet = true
    }
    
    private func toggleHistory() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showHistory.toggle()
        }
    }
    
    private func restoreFromHistory(item: (image: UIImage, compression: Float)) {
        withAnimation {
            selectedImage = item.image
            compressedImage = item.image
            compressionRatio = item.compression
        }
        showMessage("Restored image from history",
                   title: "Restored",
                   icon: "arrow.uturn.backward.circle.fill",
                   color: .teal)
    }
    
    private func removeFromHistory(at index: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            let removedItem = imageHistory.remove(at: index)
            if imageHistory.isEmpty {
                showHistory = false
            }
            if activeImage == removedItem.image {
                selectedImage = nil
                compressedImage = nil
            }
        }
        showMessage("Removed from history",
                   title: "Deleted",
                   icon: "trash.circle.fill",
                   color: .red)
    }
    
    private func clearHistory() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            imageHistory.removeAll()
            showHistory = false
        }
        showMessage("History cleared",
                   title: "History Cleared",
                   icon: "trash.fill",
                   color: .red)
    }
    
    private func showMessage(_ message: String, title: String, icon: String, color: Color) {
        modalMessage = message
        modalTitle = title
        modalIcon = icon
        modalColor = color
        showModal = true
    }
}

// MARK: - Custom Components

private struct StatBadge: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground).opacity(0.4))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
@available(iOS 16.0, *)
private struct ActionButton1: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                if #available(iOS 17.0, *) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .symbolEffect(.bounce, value: color)
                        .foregroundColor(color)
                } else {
                    // Fallback on earlier versions
                }
                Text(label)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground).opacity(0.4))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

private struct CustomSlider: View {
    @Binding var value: Float
    var range: ClosedRange<Float>
    var thumbColor: Color
    var minTrackGradient: Gradient
    var maxTrackColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(maxTrackColor)
                    .frame(height: 4)
                
                // Filled track with gradient
                Rectangle()
                    .fill(LinearGradient(gradient: minTrackGradient, startPoint: .leading, endPoint: .trailing))
                    .frame(width: CGFloat(normalizedValue) * geometry.size.width, height: 4)
                
                // Thumb with glow effect
                Circle()
                    .fill(thumbColor)
                    .frame(width: 24, height: 24)
                    .shadow(color: thumbColor.opacity(0.5), radius: 6, x: 0, y: 0)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .offset(x: CGFloat(normalizedValue) * geometry.size.width - 12)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newValue = Float(gesture.location.x / geometry.size.width)
                                let clampedValue = min(max(newValue, 0), 1)
                                value = range.lowerBound + (range.upperBound - range.lowerBound) * clampedValue
                            }
                    )
            }
        }
        .frame(height: 24)
    }
    
    private var normalizedValue: Float {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
}
@available(iOS 15.0, *)
private struct HistoryItemView: View {
    let item: (image: UIImage, compression: Float)
    let index: Int
    let primaryColor: Color
    let secondaryColor: Color
    let restoreAction: ((image: UIImage, compression: Float)) -> Void
    let copyAction: (UIImage?) -> Void
    let saveAction: (UIImage?) -> Void
    let shareAction: (UIImage?) -> Void
    let removeAction: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: item.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: [primaryColor.opacity(0.5), secondaryColor.opacity(0.3)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing),
                                lineWidth: 1)
                    )
                    .shadow(color: primaryColor.opacity(0.2), radius: 5, x: 0, y: 3)
                
                if index == 0 {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                        .padding(4)
                        .background(Circle().fill(Color.black.opacity(0.7)))
                        .offset(x: -4, y: 4)
                }
            }
            
            Text("\(Int(item.compression * 100))%")
                .font(.caption.bold())
                .foregroundColor(primaryColor)
                .padding(4)
                .padding(.horizontal, 8)
                .background(primaryColor.opacity(0.2))
                .cornerRadius(8)
        }
        .contextMenu {
            Button(action: { restoreAction(item) }) {
                Label("Restore", systemImage: "arrow.uturn.backward")
            }
            Button(action: { copyAction(item.image) }) {
                Label("Copy", systemImage: "doc.on.doc")
            }
            Button(action: { saveAction(item.image) }) {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            Button(action: { shareAction(item.image) }) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            Divider()
            Button(role: .destructive, action: { removeAction(index) }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Extensions

extension View {
    func foregroundLinearGradient(colors: [Color], startPoint: UnitPoint = .leading, endPoint: UnitPoint = .trailing) -> some View {
        self.overlay(
            LinearGradient(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
        )
        .mask(self)
    }
}

extension UIImage {
    var sizeInKB: Int {
        guard let data = self.jpegData(compressionQuality: 1.0) else { return 0 }
        return data.count / 1024
    }
}

                    struct ScaleButtonStyle: ButtonStyle {
                        func makeBody(configuration: Configuration) -> some View {
                            configuration.label
                                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                                .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
                        }
                    }
                    struct ActivityViewController: UIViewControllerRepresentable {
                        var activityItems: [Any]
                        var applicationActivities: [UIActivity]? = nil
                        
                        func makeUIViewController(context: Context) -> UIActivityViewController {
                            UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
                        }
                        
                        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
                    }
@available(iOS 16.0,*)
#Preview{
    CompressImageView()
}
