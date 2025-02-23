import SwiftUI
import PencilKit
import Combine

struct GameView: View {
    let numberOfPlayers: Int
    let timePerTurn: Int
    let pauseTime: Int
    let totalRounds: Int
    let playerColors: [Color]
    let playerNames: [String]
    let eraserEnabled: Bool
    
    @State private var canvasView = PKCanvasView()
    @State private var currentPlayerIndex = 0
    @State private var currentRound: Int = 1
    @State private var activeColorInfo: ActiveColorInfo
    @State private var timerSubscription: Cancellable?
    
    // Stato per la pausa tra i turni
    @State private var isPaused: Bool = false
    @State private var pauseCountdown: Int = 0
    @State private var pauseTimerSubscription: Cancellable?
    
    @State private var isGamePaused: Bool = false
    
    @State private var selectedTool: DrawingTool = .pen
    
    var turnProgress: Double {
        1 - (Double(activeColorInfo.timeRemaining) / Double(timePerTurn))
    }
    
    @Environment(\.dismiss) var dismiss
    @State private var showNewGameAlert: Bool = false
    
    init(numberOfPlayers: Int, timePerTurn: Int, pauseTime: Int, numberOfRounds: Int, playerColors: [Color], playerNames: [String], eraserEnabled: Bool) {
        self.numberOfPlayers = numberOfPlayers
        self.timePerTurn = timePerTurn
        self.pauseTime = pauseTime
        self.totalRounds = numberOfRounds
        self.playerColors = playerColors
        self.playerNames = playerNames
        self.eraserEnabled = eraserEnabled
        _activeColorInfo = State(initialValue: ActiveColorInfo(color: playerColors.first ?? .blue, timeRemaining: timePerTurn, isActive: true))
    }
    
    var body: some View {
        ZStack {
            playerColors[currentPlayerIndex].opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    Text("Round \(currentRound) of \(totalRounds)")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Text(String(playerNames[currentPlayerIndex].prefix(20)))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .foregroundColor(.primary)
                            .frame(maxWidth: 200, alignment: .leading)
                        Spacer()
                        if eraserEnabled {
                            HStack(spacing: 20) {
                                Button(action: { selectedTool = .pen }) {
                                    Image(systemName: "pencil")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(selectedTool == .pen ? .blue : .gray)
                                        .shadow(color: selectedTool == .pen ? .blue : .clear, radius: 10)
                                }
                                Button(action: { selectedTool = .eraser }) {
                                    Image(systemName: "eraser")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(selectedTool == .eraser ? .blue : .gray)
                                        .shadow(color: selectedTool == .eraser ? .blue : .clear, radius: 10)
                                }
                            }
                            .padding(.trailing)
                        } else {
                            Button(action: { selectedTool = .pen }) {
                                Image(systemName: "pencil")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.blue)
                                    .shadow(color: .blue, radius: 10)
                            }
                            .padding(.trailing)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 70)
                
                CanvasView(
                    canvasView: $canvasView,
                    currentColor: .constant(playerColors[currentPlayerIndex]),
                    activeColorInfo: $activeColorInfo,
                    selectedTool: $selectedTool
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.96, green: 0.96, blue: 0.86))
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding()
                .overlay(
                    NeonBorderShape()
                        .trim(from: 0, to: CGFloat(turnProgress))
                        .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .foregroundColor(playerColors[currentPlayerIndex])
                        .shadow(color: playerColors[currentPlayerIndex], radius: 10)
                        .padding(10)
                        .animation(.linear(duration: 1.0), value: turnProgress)
                )
                .onAppear {
                    canvasView.becomeFirstResponder()
                    startTurnTimer()
                }
                
                HStack {
                    Button(action: toggleGamePause) {
                        Text(isGamePaused ? "Resume" : "Pause")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .background(Color.blue.opacity(0.7))
                    .cornerRadius(10)
                    
                    Button(action: { showNewGameAlert = true }) {
                        Text("New Game")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .background(Color.green)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            
            if isPaused {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                VStack {
                    Text("Prepare for the next player")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                    Text("\(pauseCountdown)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
                .allowsHitTesting(false)
            }
        }
        .navigationBarTitle("Drawing Game", displayMode: .inline)
        .alert("Start new game?", isPresented: $showNewGameAlert) {
            Button("Yes", role: .destructive) { dismiss() }
            Button("No", role: .cancel) { }
        } message: {
            Text("The current drawing will be erased.")
        }
    }
    
    struct NeonBorderShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let start = CGPoint(x: rect.midX, y: rect.minY) 
            path.move(to: start)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: start)
            return path
        }
    }

    
    func startTurnTimer() {
        guard !isGamePaused else { return }
        timerSubscription?.cancel()
        activeColorInfo.isActive = true
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if !isGamePaused && self.activeColorInfo.timeRemaining > 0 {
                    self.activeColorInfo.timeRemaining -= 1
                } else if !isGamePaused && self.activeColorInfo.timeRemaining == 0 {
                    timerSubscription?.cancel()
                    startPause()
                }
            }
    }
    
    func startPause() {
        if pauseTime == 0 || (currentRound == totalRounds && currentPlayerIndex == numberOfPlayers - 1) {
            nextTurn()
            return
        }
        isPaused = true
        pauseCountdown = pauseTime
        activeColorInfo.isActive = false
        pauseTimerSubscription?.cancel()
        pauseTimerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.pauseCountdown > 0 {
                    self.pauseCountdown -= 1
                } else {
                    pauseTimerSubscription?.cancel()
                    nextTurn()
                }
            }
    }
    
    func nextTurn() {
        isPaused = false
        if currentPlayerIndex == numberOfPlayers - 1 {
            currentRound += 1
        }
        if currentRound > totalRounds {
            timerSubscription?.cancel()
            return
        }
        currentPlayerIndex = (currentPlayerIndex + 1) % numberOfPlayers
        activeColorInfo = ActiveColorInfo(color: playerColors[currentPlayerIndex], timeRemaining: timePerTurn, isActive: true)
        startTurnTimer()
    }
    
    func toggleGamePause() {
        if isGamePaused {
            isGamePaused = false
            startTurnTimer()
        } else {
            isGamePaused = true
            timerSubscription?.cancel()
        }
    }
    
}

