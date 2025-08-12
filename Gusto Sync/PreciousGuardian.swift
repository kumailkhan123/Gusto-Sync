import SwiftUI

@available(iOS 15.0, *)
struct PreciousGuardian: View {
    enum BubbleState {
        case sleeping
        case waking
        case guarding
        case overloaded
    }
    
    @State private var currentState: BubbleState = .sleeping
    @State private var bubbleStrength: Double = 75.0
    @State private var sparkleFrequency: Double = 2.4
    @State private var rainbowPosition: Double = 0.0
    @State private var magicLevel: Double = 0.0
    @State private var showAdvanced = false
    @State private var isSparkling = false
    
    let strengthRange: ClosedRange<Double> = 0...100
    let frequencyRange: ClosedRange<Double> = 1.0...5.0
    let rainbowRange: ClosedRange<Double> = -1.0...1.0
    
    var body: some View {
        ZStack {
            // Soft pastel background
            PastelSkyView()
            
          
            VStack(spacing: 20) {
                // Header with cute title
                BubbleHeaderView(state: $currentState)
                    
                    .padding(.top)
                  
           
                BubbleVisualizationView(
                    state: currentState,
                    strength: bubbleStrength,
                    frequency: sparkleFrequency
                )
                .frame(height: 90)
                .padding(.vertical)
                
              
                BubbleMetricsView(
                    strength: bubbleStrength,
                    frequency: sparkleFrequency,
                    rainbow: rainbowPosition,
                    magic: magicLevel
                )
                .padding(.horizontal)
                SparkleFrequencyControl(value: $sparkleFrequency, range: frequencyRange)
                // Controls with rounded corners
                ScrollView(.vertical,showsIndicators: false) {
                    VStack(spacing: 20) {
                        BubbleStrengthControl(value: $bubbleStrength, range: strengthRange)
                        
                        
                        
//                        RainbowControl(value: $rainbowPosition, range: rainbowRange)
//
                        // Advanced controls
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                showAdvanced.toggle()
                            }
                        }) {
                            HStack {
                                Text("MAGIC SETTINGS")
                                    .font(.custom("Chalkboard SE", size: 16))
                                if #available(iOS 17.0, *) {
                                    Image(systemName: showAdvanced ? "wand.and.stars" : "sparkles")
                                        .symbolEffect(.bounce, value: showAdvanced)
                                } else {
                                    // Fallback on earlier versions
                                }
                            }
                            .foregroundColor(.black)
                            .padding()
                            .background(.white.opacity(0.4))                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(LinearGradient(
                                        gradient: Gradient(colors: [.pink.opacity(0.8), .purple.opacity(0.8)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ), lineWidth: 1.5)
                            )
                        }
                        .padding(.top,20)
                        if showAdvanced {
                            AdvancedBubbleControls()
                                .transition(.scale.combined(with: .opacity))
                        }
                    } .padding(.top,-210)
                    .frame(height: 450)
                    .padding(.bottom)
                   
                }
                
                // Cute action buttons
                HStack(spacing: 20) {
                    ControlButtonView(
                        icon: "gift.fill",
                        label: "RESET",
                        color: .teal
                    )
                    .onTapGesture(perform: resetBubble)
                    .scaleEffect(isSparkling ? 1.05 : 1.0)
                    
                    if #available(iOS 17.0, *) {
                        ControlButtonView(
                            icon: currentState == .guarding ? "moon.zzz.fill" : "sparkle",
                            label: currentState == .guarding ? "NAP TIME" : "PROTECT",
                            color: currentState == .guarding ? .indigo : .yellow
                        )
                        .onTapGesture(perform: toggleBubble)
                        .symbolEffect(.bounce, value: currentState)
                    } else {
                        // Fallback on earlier versions
                    }
                }
                .padding(.bottom)
            }
            .padding(.horizontal)
            
        }
    }
    
    private func toggleBubble() {
        withAnimation(.bouncy(duration: 0.8)) {
            switch currentState {
            case .sleeping:
                currentState = .waking
                // Simulate activation sequence
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        currentState = .guarding
                        isSparkling = true
                    }
                }
            case .guarding, .overloaded:
                currentState = .sleeping
                isSparkling = false
            default: break
            }
        }
    }
    
    private func resetBubble() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            bubbleStrength = 75.0
            sparkleFrequency = 2.4
            rainbowPosition = 0.0
            currentState = .sleeping
            isSparkling = false
            showAdvanced = false
        }
    }
}

// MARK: - Subviews
@available(iOS 15.0, *)
struct PastelSkyView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.98, green: 0.85, blue: 0.90),
                Color(red: 0.85, green: 0.85, blue: 0.98),
                Color(red: 0.80, green: 0.95, blue: 0.98)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(
            ZStack {
                ForEach(0..<15) { _ in
                    Circle()
                        .foregroundColor(.white.opacity(0.05))
                        .frame(width: CGFloat.random(in: 50...200), height: CGFloat.random(in: 50...200))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                        .blur(radius: 10)
                }
            }
        )
    }
}

@available(iOS 15.0, *)
struct BubbleHeaderView: View {
    @Binding var state: PreciousGuardian.BubbleState
    
    var statusText: String {
        switch state {
        case .sleeping: return "Sweet Dreams"
        case .waking: return "Waking Up"
        case .guarding: return "Protecting!"
        case .overloaded: return "Too Much Sparkle"
        }
    }
    
    var statusColor: Color {
        switch state {
        case .sleeping: return .indigo
        case .waking: return .yellow
        case .guarding: return .mint
        case .overloaded: return .pink
        }
    }
    
    var statusEmoji: String {
        switch state {
        case .sleeping: return "💤"
        case .waking: return "🌤️"
        case .guarding: return "✨"
        case .overloaded: return "🌈"
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
           
            
            HStack(spacing: 15) {
                ForEach([PreciousGuardian.BubbleState.sleeping, .guarding, .overloaded], id: \.self) { state in
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(self.state == state ? statusColor : .white.opacity(0.3))
                        .overlay(
                            Circle()
                                .stroke(self.state == state ? statusColor.opacity(0.8) : .clear, lineWidth: 1.5)
                        )
                        .scaleEffect(self.state == state ? 1.3 : 1.0)
                }
                .background(.white.opacity(0.4))
            }
            .padding(.vertical, 5)
            
            HStack(spacing: 8) {
                Text(statusEmoji)
                    .font(.title2)
                Text(statusText)
                    .font(.custom("Chalkboard SE", size: 18))
                    .foregroundColor(statusColor)
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(statusColor.opacity(0.6), lineWidth: 1.5)
            )
        }
        .frame(height:120)
        .padding(15)
        .background(.indigo.opacity(0.4))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(LinearGradient(
                    gradient: Gradient(colors: [.pink.opacity(0.5), .purple.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: 1.5)
        )
    }
}

@available(iOS 15.0, *)
struct BubbleVisualizationView: View {
    let state: PreciousGuardian.BubbleState
    let strength: Double
    let frequency: Double
    
    @State private var phase = 0.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Soft glow background
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: [.pink.opacity(0.1), .purple.opacity(0.05)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width/2
                    ))
                    .frame(width: geo.size.width * 0.9, height: geo.size.height * 0.9)
                    .blur(radius: 10)
                
                // Bubble layers
                ForEach(0..<3) { index in
                    let scale = 1.0 - (Double(index) * 0.15)
                    let opacity = 0.6 - (Double(index) * 0.2)
                    let speed = 1.5 + Double(index)
                    
                    BubbleLayer(
                        strength: strength,
                        frequency: frequency,
                        scale: scale,
                        opacity: opacity,
                        speed: speed,
                        phase: phase
                    )
                    .frame(width: geo.size.width * scale, height: geo.size.height * scale)
                }
                
                // Sparkle core
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: [.white, .yellow, .clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.08
                    ))
                    .frame(width: geo.size.width * 0.2, height: geo.size.height * 0.2)
                    .blur(radius: 4)
                    .opacity(state == .guarding ? 1 : 0.3)
                    .overlay(
                        Circle()
                            .stroke(LinearGradient(
                                colors: [.white, .yellow.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 1)
                    )
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}

@available(iOS 15.0, *)
struct BubbleLayer: View {
    let strength: Double
    let frequency: Double
    let scale: Double
    let opacity: Double
    let speed: Double
    let phase: Double
    
    var body: some View {
        ZStack {
            // Bubble surface
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.pink.opacity(opacity), .purple.opacity(opacity)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(
                        lineWidth: 2 + (strength / 30),
                        dash: [frequency * 2, frequency * 3],
                        dashPhase: phase * speed
                    )
                )
            
            // Sparkles
            ForEach(0..<12) { i in
                let angle = Angle.degrees(Double(i) * 30)
                let distance = scale * 0.45
                
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: [.white, .yellow.opacity(0.3), .clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 4 + (strength / 30)
                    ))
                    .frame(width: 10, height: 10)
                    .offset(x: distance * cos(angle.radians), y: distance * sin(angle.radians))
                    .rotationEffect(.degrees(phase * 90 * speed))
            }
        }
    }
}

@available(iOS 15.0, *)
struct MetricView: View {
    let value: Double
    let label: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.custom("Chalkboard SE", size: 12))
                .foregroundColor(color.opacity(0.8))
            
            HStack(alignment: .bottom, spacing: 2) {
                Text("\(value, specifier: "%.1f")")
                    .font(.custom("Chalkboard SE", size: 18))
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.custom("Chalkboard SE", size: 12))
                    .foregroundColor(color.opacity(0.7))
                    .offset(y: -2)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(.gray.opacity(0.7))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.4), lineWidth: 1)
        )
    }
}

@available(iOS 15.0, *)
struct BubbleMetricsView: View {
    let strength: Double
    let frequency: Double
    let rainbow: Double
    let magic: Double
    
    var body: some View {
        HStack(spacing: 15) {
            MetricView(
                value: strength,
                label: "SNUGGLINESS",
                unit: "%",
                color: .pink
            )
            
            MetricView(
                value: frequency,
                label: "SPARKLES",
                unit: "kHz",
                color: .purple
            )
            
            MetricView(
                value: rainbow,
                label: "RAINBOW",
                unit: "🌈",
                color: rainbow >= 0 ? .mint : .orange
            )
        }
       
    }
}

@available(iOS 15.0, *)
@available(iOS 15.0, *)
struct BubbleStrengthControl: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    private let maxDragDistance: CGFloat = 150
    
    private var normalizedValue: CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
    }
    
    private var orbPosition: CGFloat {
        normalizedValue * (maxDragDistance * 2) - maxDragDistance
    }
    
    private var orbGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: [.white, .pink]),
            center: .center,
            startRadius: 0,
            endRadius: 20
        )
    }
    
    private var trackBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.pink.opacity(0.2))
            .frame(height: 30)
    }
    
    private var strengthIndicators: some View {
        HStack(spacing: 0) {
            ForEach(0..<10) { index in
                Circle()
                    .fill(index < Int(value / 10) ? .pink : .pink.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .scaleEffect(index < Int(value / 10) ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: value)
            }
        }
    }
    
    private var magicOrb: some View {
        Circle()
            .fill(orbGradient)
            .frame(width: 40, height: 40)
            .shadow(color: .pink, radius: 10)
            .overlay(
                Circle()
                    .stroke(.white, lineWidth: 2)
            )
            .offset(x: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        isDragging = true
                        let newOffset = gesture.translation.width
                        dragOffset = min(max(newOffset, -maxDragDistance), maxDragDistance)
                        let progress = (dragOffset + maxDragDistance) / (maxDragDistance * 2)
                        value = range.lowerBound + (range.upperBound - range.lowerBound) * Double(progress)
                    }
                    .onEnded { _ in
                        withAnimation(.spring()) {
                            isDragging = false
                        }
                    }
            )
            .scaleEffect(isDragging ? 1.1 : 1.0)
            .animation(.spring(), value: isDragging)
    }
    
    private var valueLabels: some View {
        HStack {
            Text("Weak")
                .font(.custom("Chalkboard SE", size: 12))
                .foregroundColor(.pink.opacity(0.7))
            
            Spacer()
            
            Text("\(value, specifier: "%.0f")%")
                .font(.custom("Chalkboard SE", size: 16))
                    .foregroundColor(.pink)
            
            Spacer()
            
            Text("Strong")
                .font(.custom("Chalkboard SE", size: 12))
                .foregroundColor(.pink.opacity(0.7))
        }.padding(.top,7)
        .padding(.horizontal, 8)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                Text("BUBBLE STRENGTH")
                    .font(.custom("Chalkboard SE", size: 16))
            }
            .foregroundColor(.pink)
            .padding(.top,-17)
            ZStack {
                trackBackground
                strengthIndicators
                magicOrb
            }
            .frame(height: 15)
            
            valueLabels
        }
        .padding()
        .background(.white.opacity(0.4))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(.pink.opacity(0.5), lineWidth: 1.5)
        )
        .onAppear {
            dragOffset = orbPosition
        }
    }
}

@available(iOS 15.0, *)
@available(iOS 15.0, *)
struct SparkleFrequencyControl: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    
    // Constants
    private let maxStars = 5
    private let starSize: CGFloat = 30
    private let starSpacing: CGFloat = 8
    
    // Derived values
    private var normalizedValue: Int {
        let valueRange = range.upperBound - range.lowerBound
        let normalized = (value - range.lowerBound) / valueRange
        return Int(round(normalized * Double(maxStars - 1)))
    }
    
    // View components
    private var header: some View {
        HStack {
            Image(systemName: "star.fill")
            Text("SPARKLE FREQUENCY")
                .font(.custom("Chalkboard SE", size: 16))
        }
        .foregroundColor(.purple)
    }
    
    private func starView(index: Int) -> some View {
        let isActive = index <= normalizedValue
        let scale: CGFloat = index == normalizedValue ? 1.3 : 1.0
        
        return Image(systemName: "star.fill")
            .font(.system(size: starSize))
            .foregroundColor(isActive ? .purple : .yellow.opacity(0.3))
            .scaleEffect(scale)
            .overlay(starOverlay(isActive: index == normalizedValue))
            .onTapGesture {
                updateValue(for: index)
            }
    }
    
    private func starOverlay(isActive: Bool) -> some View {
        Group {
            if isActive {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: starSize * 1.8, height: starSize * 1.8)
                    .blur(radius: 2)
                    .transition(.opacity)
            }
        }
    }
    
    private var starsView: some View {
        HStack(spacing: starSpacing) {
            ForEach(0..<maxStars, id: \.self) { index in
                starView(index: index)
            }
        }
        .frame(height: starSize * 1.5)
    }
    
    private var valueDisplay: some View {
        Text("\(value, specifier: "%.1f") kHz")
            .font(.custom("Chalkboard SE", size: 16).weight(.bold))
            .foregroundColor(.purple)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
    }
    
    // Actions
    private func updateValue(for index: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            let stepSize = (range.upperBound - range.lowerBound) / Double(maxStars - 1)
            value = range.lowerBound + stepSize * Double(index)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            starsView
            valueDisplay
        }.frame(height: 90)
        .padding()
        .background(.white.opacity(0.4))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(.purple.opacity(0.5), lineWidth: 1.5)
        )
    }
}
@available(iOS 15.0, *)
struct RainbowControl: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    
    // Constants
    private let arcRadius: CGFloat = 100
    private let arcThickness: CGFloat = 20
    private let sunSize: CGFloat = 30
    private let sunGlowRadius: CGFloat = 10
    
    // State
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    // Rainbow colors
    private var rainbowColors: [Color] {
        [.red, .orange, .yellow, .green, .blue, .indigo, .purple]
    }
    
    // MARK: - Computed Properties
    private var normalizedValue: CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
    }
    
    private var currentAngle: Angle {
        Angle(degrees: 180 * Double(normalizedValue) - 90)
    }
    
    private var sunPosition: CGPoint {
        CGPoint(
            x: arcRadius * cos(currentAngle.radians),
            y: arcRadius * sin(currentAngle.radians)
        )
    }
    
    private var currentColor: Color {
        let index = Int(floor(normalizedValue * Double(rainbowColors.count - 1)))
        return rainbowColors[index]
    }
    
    // MARK: - View Components
    private var header: some View {
        HStack {
            Image(systemName: value >= 0 ? "rainbow" : "cloud.rain")
            Text("RAINBOW POSITION")
                .font(.custom("Chalkboard SE", size: 16))
        }
        .foregroundColor(currentColor)
    }
    
    private func rainbowArcSegment(color: Color, index: Int) -> some View {
        ArcShape(
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: 90)
        )
        .stroke(
            color,
            style: StrokeStyle(
                lineWidth: arcThickness,
                lineCap: .round
            )
        )
        .frame(width: arcRadius * 2, height: arcRadius)
        .offset(y: -arcRadius/2)
    }
    
    private var rainbowArcs: some View {
        ForEach(0..<rainbowColors.count, id: \.self) { index in
            rainbowArcSegment(color: rainbowColors[index], index: index)
        }
    }
    
    private var sun: some View {
        Circle()
            .fill(sunGradient)
            .frame(width: sunSize, height: sunSize)
            .shadow(color: .yellow, radius: sunGlowRadius)
            .offset(x: sunPosition.x, y: sunPosition.y)
            .gesture(sunDragGesture)
            .scaleEffect(isDragging ? 1.2 : 1.0)
    }
    
    private var sunGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: [.white, .yellow]),
            center: .center,
            startRadius: 0,
            endRadius: 15
        )
    }
    
    private var sunDragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                isDragging = true
                let translationX = gesture.translation.width
                let progress = (translationX + arcRadius) / (arcRadius * 2)
                value = range.lowerBound + (range.upperBound - range.lowerBound) * Double(progress)
            }
            .onEnded { _ in
                withAnimation(.spring()) {
                    isDragging = false
                }
            }
    }
    
    private var valueLabels: some View {
        HStack {
            Text("Left")
                .font(.custom("Chalkboard SE", size: 12))
                .foregroundColor(.orange)
            
            Spacer()
            
            Text("\(value, specifier: "%.1f")")
                .font(.custom("Chalkboard SE", size: 16).weight(.bold))
                .foregroundColor(currentColor)
            
            Spacer()
            
            Text("Right")
                .font(.custom("Chalkboard SE", size: 12))
                .foregroundColor(.mint)
        }
    }
    
    // MARK: - Main Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            
            ZStack {
                rainbowArcs
                sun
            }
            .frame(height: arcRadius)
            .padding(.vertical, 10)
            
            valueLabels
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(currentColor.opacity(0.5), lineWidth: 1.5)
        )
    }
}

struct ArcShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        
        return path
    }
}

@available(iOS 15.0, *)
struct ControlButtonView: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(label)
        }
        .font(.custom("Chalkboard SE", size: 16))
        .foregroundColor(.white)
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(color)
        .cornerRadius(20)
        .shadow(color: color.opacity(0.4), radius: 8, y: 4)
    }
}

@available(iOS 15.0, *)
struct AdvancedBubbleControls: View {
    @State private var fairyDust: Double = 0.5
    @State private var moonbeams: Double = 0.25
    @State private var unicornMode = true
    
    var body: some View {
        VStack(spacing: 15) {
            Toggle(isOn: $unicornMode) {
                HStack {
                    Image(systemName: unicornMode ? "sparkles" : "moon.stars")
                    Text("UNICORN MODE")
                        .font(.custom("Chalkboard SE", size: 16))
                }
                .foregroundColor(.indigo)
            }
            .toggleStyle(CuteToggleStyle(onColor: .indigo))
            
            HStack {
                Text("FAIRY DUST")
                    .font(.custom("Chalkboard SE", size: 16))
                    .foregroundColor(.pink)
                Spacer()
                Text("\(fairyDust, specifier: "%.2f") ✨")
                    .font(.custom("Chalkboard SE", size: 16))
                    .foregroundColor(.pink)
            }
            .padding(.top,10)
            Slider(value: $fairyDust, in: 0...1)
                .tint(.pink)
            
            HStack {
                Text("MOONBEAMS")
                    .font(.custom("Chalkboard SE", size: 16))
                    .foregroundColor(.mint)
                Spacer()
                Text("\(moonbeams, specifier: "%.2f") 🌙")
                    .font(.custom("Chalkboard SE", size: 16))
                    .foregroundColor(.mint)
            }
            .padding(.top,-8)
            Slider(value: $moonbeams, in: 0...1)
                .tint(.mint)
        }
        .frame(height: 80)
        .padding()
        .background(.white.opacity(0.4))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(LinearGradient(
                    gradient: Gradient(colors: [.pink.opacity(0.5), .purple.opacity(0.5)]),
                    startPoint: .leading,
                    endPoint: .bottomTrailing
                ), lineWidth: 1.5)
        )
    }
}

// MARK: - Style Modifiers & Helpers
@available(iOS 15.0, *)
struct CuteToggleStyle: ToggleStyle {
    var onColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            RoundedRectangle(cornerRadius: 20)
                .fill(configuration.isOn ? onColor : Color.gray.opacity(0.3))
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(.white)
                        .padding(3)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .animation(.spring, value: configuration.isOn)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

// MARK: - Previews
@available(iOS 15.0, *)
struct PreciousGuardian_Previews: PreviewProvider {
    static var previews: some View {
        PreciousGuardian()
            .preferredColorScheme(.dark)
    }
}
