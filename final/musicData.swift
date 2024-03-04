//
//  musicData.swift
//  final
//
//  Created by Fallere141 on 2/26/24.
//
import MusicKit
import Foundation

enum DataLoadingState {
    case loading
    case loaded
    case failed(Error)
}

/// Manages the music data including songs, playlists, recommendations, and user customizations such as favorite songs, deleted songs, and deleted records.
//@Observable
@Observable class musicData{
    var song:MusicItemCollection<Song> = []
    var playlist:MusicItemCollection<Playlist> = []
    var recommandStation:MusicItemCollection<Station> = []
    var editablePlaylistID:[Playlist.ID] = []
    
    var deletedSongs: [Song.ID] = []
    var deletedRecord: [Song.ID] = []
    var favoriteSongs: [Song.ID] = []
    
    var loadingState: DataLoadingState = .loading

    
    private let songRequest = MusicLibraryRequest<Song>()
    
    static let shared = musicData()
    
    private let Playlistrequest = MusicLibraryRequest<Playlist>()
    
    fileprivate init() {
        // `Task` allows async task to run in initializer `init()` function
        Task{
            await initialize()
        }
    }
    
    /// Manages the music data including songs, playlists, recommendations, and user customizations such as favorite songs, deleted songs, and deleted records.
    func initialize() async {
        await fetchSong()
        await fetchPlaylist()
        fetchRrecommand()
        loadCustiomizedPlaylist()
        
        loadDeletedSongs()
        loadDeletedRecord()
        loadFavoriteSongs()
    }

    /// Toggles the favorite status of a song. If the song is already in the favorites list, it removes it; otherwise, it adds the song to the list.
    func toggleFavorite(_ song: Song) {
        if let index = favoriteSongs.firstIndex(of: song.id) {
            favoriteSongs.remove(at: index)
            saveFavoriteSongs()
            print(favoriteSongs)
        } else {
            favoriteSongs.append(song.id)
            saveFavoriteSongs()
            print("favorite: ", favoriteSongs)
        }
    }

    /// Saves the current list of favorite songs to UserDefaults.
    func saveFavoriteSongs() {
        do {
            let data = try JSONEncoder().encode(favoriteSongs)
            UserDefaults.standard.set(data, forKey: "favoriteSongs")
        } catch {
            print("Failed to save favorite songs: \(error)")
        }
    }
    
    /// Loads the list of favorite songs from UserDefaults.
    func loadFavoriteSongs() {
        guard let data = UserDefaults.standard.data(forKey: "favoriteSongs") else { return }
        do {
            let decodedFavoriteSongs = try JSONDecoder().decode([Song.ID].self, from: data)
            DispatchQueue.main.async {
                self.favoriteSongs = decodedFavoriteSongs
            }
        } catch {
            print("Failed to load favorite songs: \(error)")
        }
    }
    
    /// Marks a song as deleted by adding its ID to the list of deleted songs and saves this list.
    func markSongAsDeleted(_ song: Song) {
        guard !deletedSongs.contains(song.id) else { return }
        deletedSongs.append(song.id)
        saveDeletedSongs()
        print("deleted: ", deletedSongs)
    }
    
    /// Removes a song from the list of deleted songs.
    func removeSongFromDeleted(songId: Song.ID) {
        if let index = deletedSongs.firstIndex(of: songId) {
            deletedSongs.remove(at: index)
            saveDeletedSongs()
        }
    }
    
    /// Moves all currently deleted songs to a permanent deleted record and clears the list of deleted songs.
    func deleteListSongs() {
        deletedRecord.append(contentsOf: deletedSongs)
        deletedSongs.removeAll()
        saveDeletedSongs()
        saveDeletedRecord()
    }
    
    /// Recovers all songs marked as deleted by clearing the list of deleted songs.
    func recoverAllDeletedSongs() {
        deletedSongs.removeAll()
        saveDeletedSongs()
    }
    
    /// Saves the list of deleted songs to UserDefaults.
    func saveDeletedSongs() {
        do {
            let data = try JSONEncoder().encode(deletedSongs)
            UserDefaults.standard.set(data, forKey: "DeletedSongs")
        } catch {
            print("Failed to save deleted songs: \(error)")
        }
    }
    
    /// Loads the permanent record of deleted songs from UserDefaults.
    func loadDeletedSongs() {
        guard let data = UserDefaults.standard.data(forKey: "DeletedSongs") else { return }
        do {
            let decodedDeletedSongs = try JSONDecoder().decode([Song.ID].self, from: data)
            DispatchQueue.main.async {
                self.deletedSongs = decodedDeletedSongs
            }
        } catch {
            print("Failed to load deleted songs: \(error)")
        }
    }
    
    /// Saves the permanent record of deleted songs to UserDefaults.
    func saveDeletedRecord() {
        do {
            let data = try JSONEncoder().encode(deletedRecord)
            UserDefaults.standard.set(data, forKey: "DeletedRecord")
        } catch {
            print("Failed to save deleted record: \(error)")
        }
    }
    
    /// Loads the permanent record of deleted songs from UserDefaults.
    func loadDeletedRecord() {
        guard let data = UserDefaults.standard.data(forKey: "DeletedRecord") else { return }
        do {
            let decodedDeletedRecord = try JSONDecoder().decode([Song.ID].self, from: data)
            DispatchQueue.main.async {
                self.deletedRecord = decodedDeletedRecord
            }
        } catch {
            print("Failed to load deleted record: \(error)")
        }
    }
    
    /// Fetches the latest collection of songs from the Music Library.
    func fetchSong () async {
        
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
    
    /// Fetches the latest collection of playlists from the Music Library.
    func fetchPlaylist () async {
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
    
    /// Fetches personal recommendations, including stations, asynchronously.
    func fetchRrecommand () {
        Task{
            let status = await MusicAuthorization.request()
            switch status{
            case.authorized:
                do{
                    let request = MusicPersonalRecommendationsRequest()
                    let response = try await request.response()
                    let recommendations = response.recommendations
                    let allStations = recommendations.reduce(into: MusicItemCollection<Station>()) { $0 += $1.stations }
                    recommandStation = allStations
                }catch{
                    return
                }
            default:
                return
            }
        }
    }
    
    func findPlaylistByID (id:Playlist.ID)async ->Playlist? {
        let status = await MusicAuthorization.request()
        //         var result:MusicLibraryResponse<Song>
        switch status{
        case.authorized:
            
            var nameRequest = MusicLibraryRequest<Playlist>.init()
            nameRequest.filter(matching: \.id, equalTo: id)
            do {
                let nameResponse = try await nameRequest.response()
                print(nameResponse.items)
                //                        return nameRequest.
                return nameResponse.items.first
                
            } catch {
                
                print("name request error: \(error)")
                
            }
        default:
            return nil
        }
        return nil
    }
    
    /// Loads the IDs of customizable playlists from UserDefaults.
    func loadCustiomizedPlaylist(){
        Task{
            if let data=UserDefaults.standard.data(forKey: "CustiomizedPlaylistTest"){
                do{
                    let decodedItem = try JSONDecoder().decode([Playlist.ID].self,from: data)
                    editablePlaylistID = decodedItem
                }catch{
                    return
                }
                
            }
            await fetchPlaylist()
            
        }
    }
    
    /// Saves the IDs of customizable playlists to UserDefaults.
    func saveCustiomizedPlaylist(){
        do{
            let data = try JSONEncoder().encode(editablePlaylistID)
            UserDefaults.standard.set(data,forKey: "CustiomizedPlaylistTest")
        }catch{
            return
        }
    }
    
    public func delete(url: URL) async throws -> MusicDataResponse {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"

        let request = MusicDataRequest(urlRequest: urlRequest)
        let response = try await request.response()
        return response
    }

    /// Deletes a playlist by its ID. This method demonstrates an asynchronous request to delete a playlist.
    public func deletePlaylist(id:Playlist.ID){
        Task{
//            MusicDataRequest.tokenProvider
            let playlistURL = URL(string: "https://api.music.apple.com/v1/me/library/playlists/\(id.rawValue)")!


            do {
                let response = try await delete(url: playlistURL)
                print(response)
                print(response.data)
//                print(response.description)
                print(response.urlResponse)
                //            let response = try await deleteRequest.response()
                print("Playlist deleted successfully.")
            } catch {
                print("Failed to delete playlist:", error.localizedDescription)
            }
        }
    }

    
}
