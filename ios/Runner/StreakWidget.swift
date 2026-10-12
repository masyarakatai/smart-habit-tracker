import WidgetKit
import SwiftUI

private let widgetGroupId = "group.com.example.habittrack"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), streakCount: 5, message: "4 of 4 Done Today", isTodayPerfect: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = getEntryFromUserDefaults()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getEntryFromUserDefaults()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func getEntryFromUserDefaults() -> SimpleEntry {
        let userDefaults = UserDefaults(suiteName: widgetGroupId)
        let streak = userDefaults?.integer(forKey: "streak_count") ?? 0
        let message = userDefaults?.string(forKey: "widget_message") ?? "Complete daily habits!"
        let isPerfect = userDefaults?.bool(forKey: "is_today_perfect") ?? false

        return SimpleEntry(
            date: Date(),
            streakCount: streak,
            message: message,
            isTodayPerfect: isPerfect
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let streakCount: Int
    let message: String
    let isTodayPerfect: Bool
}

struct StreakWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text("🔥")
                    .font(.system(size: 22))
                Text("\(entry.streakCount)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 249/255, green: 115/255, blue: 22/255))
                Text("DAYS STREAK")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 249/255, green: 115/255, blue: 22/255))
            }

            Text(entry.isTodayPerfect ? "100% PERFECT 🔥" : "IN PROGRESS ⚡")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(entry.isTodayPerfect ? Color(red: 16/255, green: 185/255, blue: 129/255) : .secondary)

            Text(entry.message)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(red: 22/255, green: 30/255, blue: 46/255)
        }
    }
}

@main
struct StreakWidget: Widget {
    let kind: String = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StreakWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Habit Streak Tracker")
        .description("Keep track of your active daily streak right from your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
