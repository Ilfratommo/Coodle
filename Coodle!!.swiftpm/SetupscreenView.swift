import SwiftUI

struct SetupScreen: View {
    @State private var numberOfPlayers: Int = 2
    @State private var timePerTurn: Int = 15
    @State private var pauseTime: Int = 5
    @State private var numberOfRounds: Int = 1
    @State private var playerNames: [String] = [
        "Player 1", "Player 2", "Player 3", "Player 4", "Player 5",
        "Player 6", "Player 7", "Player 8", "Player 9", "Player 10"
    ]
    @State private var eraserEnabled: Bool = false
    @State private var showGame: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Text("Coodle!!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.top, 40)
                    
                    VStack(spacing: 20) {
                        Text("Game Settings")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("Number of players:")
                                .foregroundColor(.primary)
                            Spacer()
                            Stepper("\(numberOfPlayers)", value: $numberOfPlayers, in: 2...10)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Time per turn:")
                                .foregroundColor(.primary)
                            Spacer()
                            Stepper("\(timePerTurn) s", value: $timePerTurn, in: 1...120)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Pause between turns:")
                                .foregroundColor(.primary)
                            Spacer()
                            Stepper("\(pauseTime) s", value: $pauseTime, in: 0...30)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Number of rounds:")
                                .foregroundColor(.primary)
                            Spacer()
                            Stepper("\(numberOfRounds)", value: $numberOfRounds, in: 2...6)
                        }
                        .padding(.horizontal)
                        
                        Toggle("Enable Eraser", isOn: $eraserEnabled)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rename players:")
                                .font(.headline)
                                .foregroundColor(.primary)
                            ForEach(0..<numberOfPlayers, id: \.self) { index in
                                HStack {
                                    Circle()
                                        .fill(defaultPlayerColors[index])
                                        .frame(width: 20, height: 20)
                                    TextField("Player \(index+1)", text: Binding(
                                        get: { playerNames[index].isEmpty ? "Player \(index+1)" : playerNames[index] },
                                        set: { playerNames[index] = String($0.prefix(22)) }
                                    ))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }
                        .padding()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(radius: 5)
                    )
                    .padding(.horizontal)
                    
                    Button(action: { showGame = true }) {
                        Text("Start Game")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $showGame) {
            GameView(
                numberOfPlayers: numberOfPlayers,
                timePerTurn: timePerTurn,
                pauseTime: pauseTime,
                numberOfRounds: numberOfRounds,
                playerColors: Array(defaultPlayerColors.prefix(numberOfPlayers)),
                playerNames: Array(playerNames.prefix(numberOfPlayers)),
                eraserEnabled: eraserEnabled
            )
        }
    }
}
