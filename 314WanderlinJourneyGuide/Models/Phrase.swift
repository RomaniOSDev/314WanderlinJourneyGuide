import Foundation

enum PhraseLanguage: String, CaseIterable, Identifiable, Codable {
    case spanish
    case french
    case japanese

    var id: String { rawValue }

    var title: String {
        switch self {
        case .spanish: return "Spanish"
        case .french: return "French"
        case .japanese: return "Japanese"
        }
    }

    var flag: String {
        switch self {
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .japanese: return "🇯🇵"
        }
    }
}

struct Phrase: Identifiable, Equatable {
    let id: String
    let language: PhraseLanguage
    let english: String
    let translation: String
    let pronunciation: String

    static let library: [Phrase] = [
        Phrase(id: "es_hello", language: .spanish, english: "Hello", translation: "Hola", pronunciation: "OH-lah"),
        Phrase(id: "es_thanks", language: .spanish, english: "Thank you", translation: "Gracias", pronunciation: "GRAH-see-ahs"),
        Phrase(id: "es_please", language: .spanish, english: "Please", translation: "Por favor", pronunciation: "por fah-VOR"),
        Phrase(id: "es_excuse", language: .spanish, english: "Excuse me", translation: "Disculpe", pronunciation: "dees-KOOL-peh"),
        Phrase(id: "es_where", language: .spanish, english: "Where is...?", translation: "¿Dónde está...?", pronunciation: "DON-deh es-TAH"),
        Phrase(id: "es_bill", language: .spanish, english: "The bill, please", translation: "La cuenta, por favor", pronunciation: "lah KWAYN-tah"),
        Phrase(id: "es_help", language: .spanish, english: "I need help", translation: "Necesito ayuda", pronunciation: "neh-seh-SEE-toh ah-YOO-dah"),
        Phrase(id: "es_airport", language: .spanish, english: "Airport", translation: "Aeropuerto", pronunciation: "ah-eh-ro-PWER-toh"),

        Phrase(id: "fr_hello", language: .french, english: "Hello", translation: "Bonjour", pronunciation: "bon-ZHOOR"),
        Phrase(id: "fr_thanks", language: .french, english: "Thank you", translation: "Merci", pronunciation: "mer-SEE"),
        Phrase(id: "fr_please", language: .french, english: "Please", translation: "S'il vous plaît", pronunciation: "seel voo PLAY"),
        Phrase(id: "fr_excuse", language: .french, english: "Excuse me", translation: "Pardon", pronunciation: "par-DON"),
        Phrase(id: "fr_where", language: .french, english: "Where is...?", translation: "Où est...?", pronunciation: "oo eh"),
        Phrase(id: "fr_bill", language: .french, english: "The bill, please", translation: "L'addition, s'il vous plaît", pronunciation: "la-dee-SYON"),
        Phrase(id: "fr_help", language: .french, english: "I need help", translation: "J'ai besoin d'aide", pronunciation: "zhay buh-ZWAN ded"),
        Phrase(id: "fr_airport", language: .french, english: "Airport", translation: "Aéroport", pronunciation: "ah-eh-ro-POR"),

        Phrase(id: "jp_hello", language: .japanese, english: "Hello", translation: "こんにちは", pronunciation: "kon-nichi-wa"),
        Phrase(id: "jp_thanks", language: .japanese, english: "Thank you", translation: "ありがとう", pronunciation: "ah-ree-GAH-toh"),
        Phrase(id: "jp_please", language: .japanese, english: "Please", translation: "お願いします", pronunciation: "o-neh-GAI shee-mas"),
        Phrase(id: "jp_excuse", language: .japanese, english: "Excuse me", translation: "すみません", pronunciation: "soo-mee-mah-SEN"),
        Phrase(id: "jp_where", language: .japanese, english: "Where is...?", translation: "...はどこですか?", pronunciation: "... wa DO-ko des-ka"),
        Phrase(id: "jp_bill", language: .japanese, english: "The bill, please", translation: "お会計お願いします", pronunciation: "o-kai-kei o-neh-GAI"),
        Phrase(id: "jp_help", language: .japanese, english: "I need help", translation: "助けてください", pronunciation: "ta-soo-KEH-te koo-dah-sai"),
        Phrase(id: "jp_airport", language: .japanese, english: "Airport", translation: "空港", pronunciation: "koo-KOO")
    ]
}
