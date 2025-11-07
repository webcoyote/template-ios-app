import SwiftUI

struct HomePage: View {
    enum ParticlePreset {
        case confetti
        case snow
        case rain
        case fire
    }

    @Binding var selectedPreset: ParticlePreset
    @Binding var birthRate: Double
    @Binding var speed: Double
    @Binding var lifespan: Double
    @Binding var particleSize: Double

    var body: some View {
        Text("Home Page")
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage(
            selectedPreset: .constant(.confetti),
            birthRate: .constant(100),
            speed: .constant(0.5),
            lifespan: .constant(3.0),
            particleSize: .constant(16)
        )
    }
}
