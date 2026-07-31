import SwiftUI

struct GradientCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color("AppSurface").opacity(0.72))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.14),
                                        Color("AppPrimary").opacity(0.18)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.22), radius: 12, y: 6)
            )
    }
}

struct DestinationRow: View {
    let destination: Destination
    var onToggleVisited: () -> Void
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("AppPrimary").opacity(0.35),
                                    Color("AppAccent").opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    Image(systemName: destination.visited ? "checkmark.seal.fill" : "mappin.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color("AppPrimary"))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(destination.name)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Image(systemName: "globe")
                            .font(.caption2)
                        Text(destination.country.isEmpty ? "Unknown country" : destination.country)
                            .font(.subheadline)
                    }
                    .foregroundStyle(Color("AppTextSecondary"))

                    Text(destination.plannedDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))

                    if !destination.tags.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(destination.tags.prefix(3)) { tag in
                                Text(tag.title)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(Color("AppPrimary"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Color("AppPrimary").opacity(0.15)))
                            }
                        }
                        .padding(.top, 2)
                    }
                }

                Spacer()

                Toggle(isOn: Binding(
                    get: { destination.visited },
                    set: { _ in onToggleVisited() }
                )) {
                    Text("Visited")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .labelsHidden()
                .tint(Color("AppPrimary"))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color("AppSurface").opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct ChecklistRow: View {
    let item: ChecklistItem
    var onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.completed ? Color("AppPrimary") : Color("AppTextSecondary"))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(item.completed ? Color("AppTextSecondary") : Color("AppTextPrimary"))
                    .strikethrough(item.completed, color: Color("AppTextSecondary"))

                if !item.destinationTag.isEmpty {
                    Text(item.destinationTag)
                        .font(.caption2)
                        .foregroundStyle(Color("AppPrimary"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color("AppPrimary").opacity(0.15)))
                }
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("AppSurface").opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

struct PhraseRow: View {
    let phrase: Phrase
    let isFavourite: Bool
    var onToggleFavourite: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(phrase.english)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))

                Text(phrase.translation)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Color("AppPrimary"))

                Text(phrase.pronunciation)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }

            Spacer()

            Button(action: onToggleFavourite) {
                Image(systemName: isFavourite ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(isFavourite ? Color("AppAccent") : Color("AppTextSecondary"))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("AppSurface").opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

struct DestinationChip: View {
    let title: String
    let isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "mappin")
                    .font(.caption2)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color("AppBackground") : Color("AppTextPrimary"))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        isSelected
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppAccent")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            : AnyShapeStyle(Color("AppSurface").opacity(0.8))
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct EmptyStateView: View {
    let systemImage: String
    let message: String

    var body: some View {
        VStack(spacing: 18) {
            Image("EmptyArt")
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color("AppPrimary").opacity(0.35), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 10, y: 4)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct TravelBannerHeader: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("BannerTravel")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .opacity(0.85)
                .allowsHitTesting(false)

            LinearGradient(
                colors: [
                    Color("AppBackground").opacity(0.15),
                    Color("AppBackground").opacity(0.75)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Travel Bucket")
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Your next journey starts here")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}
