import SwiftUI

struct SliderView: View {
    
    @State private var sliderValue: Int = 50
    
    var body: some View {
        VStack {
            Spacer()
            CustomSlider(
                value: $sliderValue,
                range: 1...100,
                trackHeight: 20,
                thumbSize: 40
            )
            .padding()
            .frame(maxHeight: 50)
            Text("当前值: \(sliderValue)")

            Spacer()
        }
    }
}


struct CustomSlider: View {
    @Binding var value: Int // 绑定的数值
    let range: ClosedRange<Int> // 数值范围（如 0...1）
    let trackHeight: CGFloat // 轨道高度
    let thumbSize: CGFloat // 滑块大小
    
    @State var zstackWidth = UIScreen.main.bounds.width
    @State var zstackHeight = UIScreen.main.bounds.height / 10
    
    // 初始化配置
    init(
        value: Binding<Int>,
        range: ClosedRange<Int> = 1...100,
        trackHeight: CGFloat = 4,
        thumbSize: CGFloat = 24
    ) {
        self._value = value
        self.range = range
        self.trackHeight = trackHeight
        self.thumbSize = thumbSize
    }
    
    // 计算当前滑块位置
    private var percentage: Double {
        let percentage = Double((value - range.lowerBound)) / Double((range.upperBound - range.lowerBound))
            
        logger.warning("percentage:\(percentage), \((338 - thumbSize) * CGFloat(percentage))")
        return percentage
    }
    
    var body: some View {
            ZStack(alignment: .leading) {
                // 自定义轨道背景
                RoundedRectangle(cornerRadius: trackHeight / 2)
                    .fill(
                        LinearGradient(
                            colors: [.black, .gray, .blue, .orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: trackHeight)
                
                // 自定义滑块（Thumb）
                Circle()
                    .fill(.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(radius: 2)
                    .offset(x: (zstackWidth - thumbSize) * CGFloat(percentage))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                // 计算拖动位置对应的数值
                                let dragX = gesture.location.x
                                let width = zstackWidth - thumbSize
                                let proportion: Double = dragX / width
                                let newValue = proportion * Double((range.upperBound - range.lowerBound) + range.lowerBound)
                                value = min(max(Int(newValue), range.lowerBound), range.upperBound)

                                logger.warning("dragX: \(dragX), width: \(width) newValue: \(newValue) value:\(value), lowerBound: \(range.lowerBound) upperBound: \(range.upperBound)")
                            }
                    )
            }
            .frame(height: thumbSize) // 控制整体高度
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .global)
            } action: { newValue in
                zstackWidth = newValue.width
                zstackHeight = newValue.height
            }
    }
}

#Preview {
    SliderView()
}
