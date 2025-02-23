import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var currentColor: Color
    @Binding var activeColorInfo: ActiveColorInfo
    @Binding var selectedTool: DrawingTool
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        updateTool(on: canvasView)
        canvasView.becomeFirstResponder()
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        updateTool(on: uiView)
        uiView.isUserInteractionEnabled = activeColorInfo.isActive
    }
    
    private func updateTool(on uiView: PKCanvasView) {
        switch selectedTool {
        case .pen:
            uiView.tool = PKInkingTool(.pen, color: UIColor(currentColor), width: 5)
        case .eraser:
            uiView.tool = PKEraserTool(.bitmap)
        }
    }
}

