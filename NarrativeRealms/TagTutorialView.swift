import SwiftUI

struct TagTutorialView: View {
    @Binding var tutorialStep: Int
    var onRestart: () -> Void
    private let textWidth: CGFloat = 280
    @State private var isNextEnabled = true
    @Environment(\.openWindow) private var openWindow
    @State private var requiredSnapTarget: String?
    
    private var stateDebug: String {
        """
        Step: \(tutorialStep)
        Next Enabled: \(isNextEnabled)
        Required Target: \(requiredSnapTarget ?? "none")
        """
    }
    
    private var currentStep: TutorialStep? {
        TutorialContent.getStep(tutorialStep)
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(currentStep?.image ?? "tagImg")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            
            Text(currentStep?.header ?? "Tag")
                .font(.headline)
                .padding(.top, 8)
            
            if let step = currentStep {
                Text(step.message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .frame(width: textWidth)
                    .padding(.horizontal, 8)
                    .onChange(of: step.id) { _, _ in
                        handleStepAction()
                    }
            }
            
            Divider()
                .padding(.vertical, 8)
            
            navigationButtons
            
            Spacer()
        }
        .padding()
        .fixedSize(horizontal: true, vertical: false)
        .onReceive(NotificationCenter.default.publisher(for: .updateNextButtonState)) { notification in
            if let isEnabled = notification.userInfo?["isEnabled"] as? Bool {
                isNextEnabled = isEnabled
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .tagSnappedToIndicator)) { notification in
            print("📱 Received tagSnappedToIndicator notification")
            print("Notification Names Match: \(Notification.Name.tagSnappedToIndicator.rawValue)")
            print("Current required target: \(requiredSnapTarget ?? "none")")
            if let snappedTo = notification.userInfo?["indicator"] as? String {
                print("Snapped to: \(snappedTo)")
                if snappedTo == requiredSnapTarget {
                    print("✅ Match found! Enabling next button")
                    isNextEnabled = true
                    requiredSnapTarget = nil
                } else {
                    print("❌ No match: \(snappedTo) != \(requiredSnapTarget ?? "none")")
                }
            }
        }
        .onAppear {
            print("🎯 TagTutorialView appeared, current step: \(tutorialStep), required target: \(requiredSnapTarget ?? "none")")
            NotificationCenter.default.addObserver(
                forName: .tagSnappedToIndicator,
                object: nil,
                queue: .main
            ) { notification in
                print("📱 Received tagSnappedToIndicator notification")
                if let snappedTo = notification.userInfo?["indicator"] as? String {
                    print("Snapped to: \(snappedTo), Required: \(requiredSnapTarget ?? "none")")
                    if snappedTo == requiredSnapTarget {
                        print("✅ Match found! Enabling next button")
                        isNextEnabled = true
                        requiredSnapTarget = nil
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var navigationButtons: some View {
        HStack {
            if tutorialStep > 1 {
                Button("Back") {
                    tutorialStep -= 1
                }
                .buttonStyle(.plain)
                .padding(.vertical, 8)
            }
            
            Spacer()
            
            if tutorialStep == 29 {
                Button("Restart") {
                    onRestart()
                }
                .padding(.vertical, 8)
                .buttonStyle(.borderedProminent)
            } else {
                Button("Next") {
                    tutorialStep += 1
                }
                .padding(.vertical, 8)
                .buttonStyle(.borderedProminent)
                .disabled(!isNextEnabled ||
                    (currentStep?.isSpecialStep ?? false))
            }
        }
    }
    
    private func handleStepAction() {
        guard let step = currentStep else { return }
        
        for action in step.actions {
            switch action {
            case .openPalette:
                openWindow(value: PaletteWindowID(id: 1))
            case .disableNextButton:
                isNextEnabled = false
            case .enableNextButton:
                isNextEnabled = true
            case .showModel(let modelName):
                NotificationCenter.default.post(
                    name: .showModel,
                    object: nil,
                    userInfo: ["modelName": modelName]
                )
            case .playAnimation(let entityName):
                        NotificationCenter.default.post(
                            name: .playAnimation,
                            object: nil,
                            userInfo: ["entityName": entityName]
                        )
            case .requireSnapTo(let target):
                print("📍 Setting required snap target: \(target)")
                requiredSnapTarget = target
                isNextEnabled = false
                print("Current state after requireSnapTo:")
                print(stateDebug)
            case .hideModel(let modelName):
                NotificationCenter.default.post(
                    name: .hideModel,
                    object: nil,
                    userInfo: ["modelName": modelName]
                )
            case .showModels(let modelNames):
                NotificationCenter.default.post(
                    name: .showModels,
                    object: nil,
                    userInfo: ["modelNames": modelNames]
                )
            case .hideModels(let modelNames):
                NotificationCenter.default.post(
                    name: .hideModels,
                    object: nil,
                    userInfo: ["modelNames": modelNames]
                )
            case .none:
                break
            }
        }
    }
}

// Add notification name if not already defined elsewhere
extension Notification.Name {
    static let updateNextButtonState = Notification.Name("updateNextButtonState")
    static let tagSnappedToIndicator = Notification.Name("tagSnappedToIndicator")
}


