import SwiftUI
import StrandDesign

// MARK: - Activity tab (W3P)
//
// The training home. Workouts, live heart rate, Breathe, Intervals and the Lift Log used to be five rows
// inside More; they are the things a wearer opens while moving, so they get a tab of their own. This root
// only routes: every destination is the same screen More used to push.

struct ActivityTabView: View {
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScreenScaffold(title: "Activity", subtitle: "Effort and training") {
            NavigationLink(value: TabRoute.metric(HeroRingMetric.effort)) {
                hero
            }
            .buttonStyle(.plain)

            NavigationLink {
                pushed(LiveView())
            } label: {
                Text("Start or follow a workout")
                    .font(StrandFont.headline)
                    .foregroundStyle(StrandPalette.surfaceBase)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(Capsule().fill(StrandPalette.textPrimary))
            }
            .buttonStyle(.plain)

            LazyVGrid(columns: columns, spacing: 12) {
                NavigationLink { pushed(BreathingView()) } label: {
                    tile("Breathe", "HRV-paced, with wrist cues", icon: "wind", tint: StrandPalette.statusPositive)
                }
                NavigationLink { pushed(IntervalTimerView()) } label: {
                    tile("Intervals", "A haptic timer", icon: "timer", tint: StrandPalette.chargeBright)
                }
                NavigationLink { pushed(LiftLogView()) } label: {
                    tile("Lift log", "Programs, sets and reps", icon: "dumbbell", tint: StrandPalette.restBright)
                }
                NavigationLink(value: TabRoute.workouts) {
                    tile("Workouts", "Every session, by sport", icon: "figure.run", tint: StrandPalette.effortBright)
                }
            }
            .buttonStyle(.plain)

            VStack(spacing: 0) {
                NavigationLink(value: TabRoute.fullDayChart) {
                    row("Heart rate today", "The whole day at full resolution", icon: "waveform.path.ecg")
                }
                Rectangle().fill(StrandPalette.hairline).frame(height: 0.5).padding(.leading, 56)
                NavigationLink(value: TabRoute.stress) {
                    row("Stress", "Autonomic load through the day", icon: "bolt.heart")
                }
                Rectangle().fill(StrandPalette.hairline).frame(height: 0.5).padding(.leading, 56)
                NavigationLink(value: TabRoute.health) {
                    row("Health monitor", "Live vitals against your baseline", icon: "heart.text.square")
                }
            }
            .buttonStyle(.plain)
            .noopPanel()
        }
    }

    /// The Effort entry point. It carries no reading of its own: the metric page it opens owns today's
    /// value, trend and zones, so there is one source for the number rather than a copy here.
    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Effort").font(StrandFont.title2).foregroundStyle(StrandPalette.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(StrandPalette.textTertiary)
            }
            Text("Today's load, your trend and time in each heart-rate zone.")
                .font(StrandFont.subhead)
                .foregroundStyle(StrandPalette.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .noopPanel(tint: StrandPalette.effortDeep)
    }

    private func tile(_ title: LocalizedStringKey, _ subtitle: LocalizedStringKey,
                      icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(tint)
            Spacer(minLength: 8)
            Text(title).font(StrandFont.headline).foregroundStyle(StrandPalette.textPrimary)
            Text(subtitle)
                .font(StrandFont.caption)
                .foregroundStyle(StrandPalette.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
        .noopPanel(tint: tint)
    }

    private func row(_ title: LocalizedStringKey, _ subtitle: LocalizedStringKey, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(StrandPalette.textSecondary)
                .frame(width: 26, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(StrandFont.body).foregroundStyle(StrandPalette.textPrimary)
                Text(subtitle).font(StrandFont.caption).foregroundStyle(StrandPalette.textTertiary)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(StrandPalette.textTertiary)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 60)
        .contentShape(Rectangle())
    }

    /// The wrapper More applies to a pushed screen: flat canvas, inline title, transparent bar.
    private func pushed<V: View>(_ view: V) -> some View {
        view
            .background(StrandPalette.surfaceBase.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
    }
}
