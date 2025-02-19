import Foundation


enum NewsCategory {
    case all, campaigns, announcements
}

enum NewsType {
    case campaign
    case announcement
}

struct NewsItem: Identifiable {
    let id = UUID() // Her habere benzersiz kimlik
    let title: String
    let description: String
    let image: String
    let type: NewsType
}
