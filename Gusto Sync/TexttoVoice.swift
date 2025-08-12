import SwiftUI
import AVFoundation

@available(iOS 16.0, *)
struct TextToSpeechView: View {
    @State private var textToSpeak = ""
    @State private var isSpeaking = false
    @State private var audioLevels: [CGFloat] = Array(repeating: 0.1, count: 12)
    @State private var selectedVoice = AVSpeechSynthesisVoiceIdentifierAlex
    @State private var speakingRate: Double = 0.5
    @State private var showingVoicePicker = false
    @State private var showingSettings = false
    @State private var showingHistory = false
    @State private var savedTexts: [String] = []
    @State private var pitch: Double = 1.0
    @State private var isPaused = false
    @State private var currentWordRange: NSRange?
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("highlightColorHex") private var highlightColorHex = "#0000FF"

    private var highlightColor: Color {
        Color(hex: highlightColorHex) ?? .blue
    }
    
    private let synthesizer = AVSpeechSynthesizer()
    private let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.contains("en-") }
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                dynamicBackground
                    .onTapGesture {
                        dismissKeyboard()
                    }
                
                VStack(spacing: 0) {
                    audioVisualizer
                    
                    textEditorView
                        .padding(.horizontal)
                    
                    playbackControls
                    
                    configurationControls
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Text To Speech")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingHistory.toggle()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingVoicePicker) {
                voicePickerSheet
            }
            .sheet(isPresented: $showingSettings) {
                settingsSheet
            }
            .sheet(isPresented: $showingHistory) {
                historySheet
            }
            .onAppear {
                setupSynthesizer()
                loadHistory()
            }
            .onDisappear {
                stopSpeaking()
            }
            .onReceive(timer) { _ in
                updateAudioLevels()
            }
            .tint(.blue)
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
    
    // MARK: - Subviews
    
    private var dynamicBackground: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let averageLevel = audioLevels.reduce(0, +) / CGFloat(audioLevels.count)
            
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.yellow.opacity(0.3),
                        Color.white.opacity(0.3)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                Circle()
                    .fill(.blue.opacity(0.15))
                    .frame(width: width * (0.5 + averageLevel * 0.5))
                    .position(x: width * 0.3, y: height * 0.7)
                    .blur(radius: 30)
                    .scaleEffect(1 + averageLevel * 0.2)
                    .animation(.easeOut(duration: 0.3), value: averageLevel)
                
                ForEach(0..<15, id: \.self) { i in
                    Circle()
                        .fill(.blue.opacity(Double.random(in: 0.05...0.2)))
                        .frame(width: CGFloat.random(in: 2...8))
                        .position(
                            x: CGFloat.random(in: 0...width),
                            y: CGFloat.random(in: 0...height)
                        )
                        .modifier(
                            ParticleEffect(
                                speed: Double.random(in: 0.5...2),
                                direction: Double.random(in: 0...360),
                                isActive: isSpeaking
                            )
                        )
                }
            }
        }
    }
    
    private var audioVisualizer: some View {
        HStack(spacing: 4) {
            ForEach(0..<audioLevels.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(.blue)
                    .frame(
                        width: 8,
                        height: 30 * audioLevels[index]
                    )
                    .scaleEffect(y: isSpeaking ? 1 : 0.1, anchor: .bottom)
                    .animation(
                        .interpolatingSpring(stiffness: 50, damping: 10)
                        .delay(Double(index) * 0.03),
                        value: isSpeaking
                    )
            }
        }
        .frame(height: 60)
        .padding(.vertical)
    }
    
    private var textEditorView: some View {
        ZStack(alignment: .topLeading) {
            // Always keep the TextEditor in the view hierarchy
            TextEditor(text: $textToSpeak)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isDarkMode ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
                )
                .frame(height: 200)
                .foregroundColor(isDarkMode ? .white : .black)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.blue.opacity(0.5), lineWidth: 1)
                )
                .opacity(currentWordRange == nil ? 1 : 0)
                .padding(.bottom)
            
            // Placeholder text
            if textToSpeak.isEmpty && currentWordRange == nil {
                Text("Enter text to speak...")
                    .foregroundColor(.gray)
                    .padding(.top, 15)
                    .padding(.leading, 20)
                    .allowsHitTesting(false)
            }
            
            // Highlighted word view
            if let range = currentWordRange, !textToSpeak.isEmpty {
                let nsText = textToSpeak as NSString
                let precedingText = nsText.substring(to: range.location)
                let currentWord = nsText.substring(with: range)
                let followingText = nsText.substring(from: range.location + range.length)
                
                HStack(spacing: 0) {
                    Text(precedingText)
                    Text(currentWord)
                        .foregroundColor(highlightColor)
                        .bold()
                    Text(followingText)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isDarkMode ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
                )
                .fixedSize(horizontal: false, vertical: true)
                .transition(.opacity)
                .allowsHitTesting(false)
            }
        }
    }
    
    private var playbackControls: some View {
        HStack(spacing: 30) {
            Button {
                saveCurrentText()
            } label: {
                Image(systemName: "bookmark")
                    .font(.title2)
                    .padding(15)
                    .background(Circle().fill(.blue.opacity(0.2)))
            }
            
            Button {
                if isSpeaking {
                    if isPaused {
                        resumeSpeaking()
                    } else {
                        pauseSpeaking()
                    }
                } else {
                    speakText()
                }
            } label: {
                Image(systemName: isSpeaking ? (isPaused ? "play.fill" : "pause.fill") : "play.fill")
                    .font(.title)
                    .padding(25)
                    .background(Circle().fill(.blue))
                    .foregroundColor(.white)
            }
            .scaleEffect(isSpeaking ? 1.1 : 1.0)
            .animation(.spring(), value: isSpeaking)
            
            Button {
                stopSpeaking()
            } label: {
                Image(systemName: "stop.fill")
                    .font(.title2)
                    .padding(15)
                    .background(Circle().fill(.blue.opacity(0.2)))
            }
            .disabled(!isSpeaking && !isPaused)
        }
        .padding(.vertical)
    }
    
    private var configurationControls: some View {
        VStack(spacing: 15) {
            Button {
                showingVoicePicker.toggle()
            } label: {
                HStack {
                    Image(systemName: "person.wave.2.fill")
                    Text(voiceDisplayName(for: selectedVoice))
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isDarkMode ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
                )
            }
            
            HStack {
                Image(systemName: "tortoise.fill")
                Slider(value: $speakingRate, in: 0.2...0.8)
                Image(systemName: "hare.fill")
            }
            .padding(.horizontal)
            
            HStack {
                Image(systemName: "arrow.down.to.line")
                Slider(value: $pitch, in: 0.5...2.0)
                Image(systemName: "arrow.up.to.line")
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
    
    private var voicePickerSheet: some View {
        NavigationStack {
            List(voices, id: \.identifier) { voice in
                Button {
                    selectedVoice = voice.identifier
                    showingVoicePicker = false
                } label: {
                    HStack {
                        Text(voiceDisplayName(for: voice.identifier))
                        Spacer()
                        if voice.identifier == selectedVoice {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Voice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingVoicePicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var settingsSheet: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                    
                    ColorPicker("Highlight Color", selection: Binding(
                        get: { self.highlightColor },
                        set: { newColor in
                            self.highlightColorHex = newColor.toHex()
                        }
                    ))
                }
                
                Section("Speech Settings") {
                    Stepper("Default Rate: \(String(format: "%.1f", speakingRate))",
                           value: $speakingRate, in: 0.2...0.8, step: 0.1)
                    
                    Stepper("Default Pitch: \(String(format: "%.1f", pitch))",
                           value: $pitch, in: 0.5...2.0, step: 0.1)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingSettings = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var historySheet: some View {
        NavigationStack {
            Group {
                if savedTexts.isEmpty {
                    VStack {
                        Image(systemName: "clock.badge.questionmark")
                            .font(.system(size: 50))
                            .padding()
                        Text("No saved texts yet")
                            .font(.headline)
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(savedTexts.indices, id: \.self) { index in
                            Button {
                                textToSpeak = savedTexts[index]
                                showingHistory = false
                            } label: {
                                Text(savedTexts[index])
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                            }
                        }
                        .onDelete { indices in
                            savedTexts.remove(atOffsets: indices)
                            saveHistory()
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingHistory = false
                    }
                }
                
                if !savedTexts.isEmpty {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Clear All") {
                            savedTexts.removeAll()
                            saveHistory()
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Speech Functions
    
    private func setupSynthesizer() {
        synthesizer.delegate = SpeechDelegate(
            didStart: { [self] utterance in
                isSpeaking = true
                isPaused = false
            },
            didFinish: { [self] utterance in
                isSpeaking = false
                isPaused = false
                currentWordRange = nil
            },
            didPause: { [self] in
                isPaused = true
            },
            didContinue: { [self] in
                isPaused = false
            },
            willSpeakRange: { [self] range, utterance in
                currentWordRange = range
            }
        )
    }
    
    private func speakText() {
        guard !textToSpeak.isEmpty else { return }
        
        DispatchQueue.main.async {
            if self.synthesizer.isSpeaking {
                self.synthesizer.stopSpeaking(at: .immediate)
            }
            
            let utterance = AVSpeechUtterance(string: self.textToSpeak)
            
            if let voice = AVSpeechSynthesisVoice(identifier: self.selectedVoice) {
                utterance.voice = voice
            } else {
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            }
            
            utterance.rate = Float(self.speakingRate)
            utterance.pitchMultiplier = Float(self.pitch)
            
            self.synthesizer.speak(utterance)
            self.isSpeaking = true
        }
    }
    
    private func pauseSpeaking() {
        synthesizer.pauseSpeaking(at: .word)
        isPaused = true
    }
    
    private func resumeSpeaking() {
        synthesizer.continueSpeaking()
        isPaused = false
    }
    
    private func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        isPaused = false
        currentWordRange = nil
    }
    
    // MARK: - Helper Functions
    
    private func voiceDisplayName(for identifier: String) -> String {
        if let voice = voices.first(where: { $0.identifier == identifier }) {
            return voice.name
                .replacingOccurrences(of: " (Enhanced)", with: "")
                .replacingOccurrences(of: " (Premium)", with: "")
        }
        return "Default"
    }
    
    private func updateAudioLevels() {
        if isSpeaking && !isPaused {
            withAnimation(.interactiveSpring()) {
                audioLevels = audioLevels.map { _ in
                    CGFloat.random(in: 0.3...1.0)
                }
            }
        } else {
            withAnimation(.easeOut(duration: 0.5)) {
                audioLevels = audioLevels.map { level in
                    max(0.1, level * 0.8)
                }
            }
        }
    }
    
    private func saveCurrentText() {
        guard !textToSpeak.isEmpty else { return }
        if !savedTexts.contains(textToSpeak) {
            savedTexts.insert(textToSpeak, at: 0)
            saveHistory()
        }
    }
    
    private func saveHistory() {
        UserDefaults.standard.set(savedTexts, forKey: "savedTexts")
    }
    
    private func loadHistory() {
        savedTexts = UserDefaults.standard.stringArray(forKey: "savedTexts") ?? []
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Supporting Types

struct ParticleEffect: GeometryEffect {
    var speed: Double
    var direction: Double
    var isActive: Bool
    
    var animatableData: Double {
        get { direction }
        set { direction = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let radians = direction * .pi / 180
        let distance = isActive ? speed * 10 : 0
        
        let xOffset = distance * cos(radians)
        let yOffset = distance * sin(radians)
        
        return ProjectionTransform(
            CGAffineTransform(translationX: xOffset, y: yOffset)
        )
    }
}

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    let didStart: (AVSpeechUtterance) -> Void
    let didFinish: (AVSpeechUtterance) -> Void
    let didPause: () -> Void
    let didContinue: () -> Void
    let willSpeakRange: (NSRange, AVSpeechUtterance) -> Void
    
    init(didStart: @escaping (AVSpeechUtterance) -> Void,
         didFinish: @escaping (AVSpeechUtterance) -> Void,
         didPause: @escaping () -> Void,
         didContinue: @escaping () -> Void,
         willSpeakRange: @escaping (NSRange, AVSpeechUtterance) -> Void) {
        self.didStart = didStart
        self.didFinish = didFinish
        self.didPause = didPause
        self.didContinue = didContinue
        self.willSpeakRange = willSpeakRange
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        didStart(utterance)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        didFinish(utterance)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        didPause()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        didContinue()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        willSpeakRange(characterRange, utterance)
    }
}

// MARK: - Extensions

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    func toHex() -> String {
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let a = Float(components.count >= 4 ? components[3] : 1.0)
        
        if a != 1.0 {
            return String(format: "#%02lX%02lX%02lX%02lX",
                         lroundf(r * 255),
                         lroundf(g * 255),
                         lroundf(b * 255),
                         lroundf(a * 255))
        } else {
            return String(format: "#%02lX%02lX%02lX",
                         lroundf(r * 255),
                         lroundf(g * 255),
                         lroundf(b * 255))
        }
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct TextToSpeechView_Previews: PreviewProvider {
    static var previews: some View {
        TextToSpeechView()
    }
}
