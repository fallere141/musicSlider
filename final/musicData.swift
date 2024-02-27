//
//  musicData.swift
//  final
//
//  Created by Fallere141 on 2/26/24.
//
import MusicKit
import Foundation

//@Observable
@Observable class musicData{
    var song:MusicItemCollection<Song> = []
    var playlist:MusicItemCollection<Playlist> = []
    var recommandStation:MusicItemCollection<Station> = []
    
    private let songRequest = MusicLibraryRequest<Song>()
    
    static let shared = musicData()
    
    private let Playlistrequest = MusicLibraryRequest<Playlist>()
    
    fileprivate init() {
        // `Task` allows async task to run in initializer `init()` function
        Task{
            await fetechSong()
            await fetechPlaylist()
            fetechRrecommand()
//            let request = MusicPersonalRecommendationsRequest()
//            let response = try await request.response()
//
//            print(response.recommendations)
        }
    
        
//        /// Adds an item to the data collection.
//        func addItem(_ item: Item) {
//            items.insert(item, at: 0)
//            print("image added")
//        }
//        
//        /// Removes an item from the data collection.
//
//        func removeItem(_ item: Item) {
//            // Remove from items
//            if let index = items.firstIndex(of: item) {
//                items.remove(at: index)
//            }
//            // Remove from favoriteItems
//            if let favoriteIndex = favoriteItems.firstIndex(of: item) {
//                favoriteItems.remove(at: favoriteIndex)
//            }
//
//            FileManager.default.removeItemFromDocumentDirectory(url: item.url)
//            print("Image removed from all collections")
//        }
//        
//        func deleteItem(_ item: Item) {
//            if let index = items.firstIndex(of: item) {
//                deletedItems.insert(item, at: 0)
//                items.remove(at: index)
//                print("image delete")
//            }
//        }
//
//        func removeAllDeletedItems() {
//            for item in deletedItems {
//                FileManager.default.removeItemFromDocumentDirectory(url: item.url)
//            }
//            deletedItems.removeAll()
//            print("All deleted images have been removed.")
//        }
//
//        func nextItem(after currentItem: Item) -> Item? {
//            guard let currentIndex = items.firstIndex(of: currentItem) else {
//                return nil
//            }
//            let nextIndex = currentIndex + 1
//            return items.indices.contains(nextIndex) ? items[nextIndex] : items.first
//        }
//        
//        func toggleFavorite(_ item: Item) {
//            if favoriteItems.firstIndex(of: item) != nil {
//                favoriteItems.insert(item, at: 0)
//            } else {
//                favoriteItems.append(item)
//                print("image toggleFavorite")
//            }
//        }
//
//        func isFavorite(_ item: Item) -> Bool {
//            favoriteItems.contains(item)
//        }
//        
//        func addItemToFolder(_ item: Item, folderName: String) {
//            if let index = folders.firstIndex(where: { $0.name == folderName }) {
//                folders[index].items.append(item)
//                print("Image added to folder: \(folderName)")
//            } else {
//                print("Folder not found.")
//            }
//        }

    }
    
    
    
    func fetechSong() async{
        
        let status = await MusicAuthorization.request()
//         var result:MusicLibraryResponse<Song>
        switch status{
        case.authorized:
            do{
                
                let result = try await songRequest.response()
                song = result.items
//                return result.items
                
            }catch{
                return
            }
        default:
            return
        }
    }
    

    
    func fetechPlaylist()async{
        let status = await MusicAuthorization.request()
        switch status{
        case.authorized:
            do{
                let result = try await Playlistrequest.response()
                                self.playlist = result.items
//                return result.items
            }catch{
                return
            }
        default:
            return
            
        }
    }
    
    
    
    func fetechRrecommand(){
        Task{
           let status = await MusicAuthorization.request()
            switch status{
            case.authorized:
                do{
                    let request = MusicPersonalRecommendationsRequest()
                    let response = try await request.response()
                    let recommendations = response.recommendations
                    let allStations = recommendations.reduce(into: MusicItemCollection<Station>()) { $0 += $1.stations }
//                    self.songs = allStations.compactMap({
//                        return .init(name:$0.name,artest:$0.description,imageURL: $0.artwork?.url(width: 75, height: 75))
//                    })
                    recommandStation = allStations
                }catch{
                    return
                }
            default:
                return
            }
        }
    }
    
    
}
