import SwiftUI

struct PhraseTranslatorView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var selectedLanguage: PhraseLanguage = .spanish
    @State private var searchText = ""
    @State private var showFavouritesOnly = false

    private var filteredPhrases: [Phrase] {
        Phrase.library.filter { phrase in
            phrase.language == selectedLanguage &&
            (!showFavouritesOnly || store.isFavouritePhrase(phrase.id)) &&
            (searchText.isEmpty ||
             phrase.english.localizedCaseInsensitiveContains(searchText) ||
             phrase.translation.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Language", selection: $selectedLanguage) {
                ForEach(PhraseLanguage.allCases) { language in
                    Text("\(language.flag) \(language.title)").tag(language)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 8)

            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color("AppTextSecondary"))
                    TextField("Search phrases", text: $searchText)
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("AppSurface"))
                )

                Button {
                    FeedbackHelper.tap()
                    showFavouritesOnly.toggle()
                } label: {
                    Image(systemName: showFavouritesOnly ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(showFavouritesOnly ? Color("AppPrimary") : Color("AppTextSecondary"))
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("AppSurface"))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if filteredPhrases.isEmpty {
                Spacer()
                EmptyStateView(
                    systemImage: "character.bubble",
                    message: showFavouritesOnly
                        ? "No favourite phrases for this language."
                        : "No phrases match your search."
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPhrases) { phrase in
                            PhraseRow(
                                phrase: phrase,
                                isFavourite: store.isFavouritePhrase(phrase.id)
                            ) {
                                FeedbackHelper.tap()
                                store.toggleFavouritePhrase(phrase.id)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
        .withScreenBackground()
        .navigationTitle("Phrase Translator")
        .navigationBarTitleDisplayMode(.inline)
    }
}
