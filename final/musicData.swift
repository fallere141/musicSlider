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
    var editablePlaylistID:[Playlist.ID] = []
    
    private let songRequest = MusicLibraryRequest<Song>()
    
    static let shared = musicData()
    
    private let Playlistrequest = MusicLibraryRequest<Playlist>()
    
    fileprivate init() {
        // `Task` allows async task to run in initializer `init()` function
        Task{
            await fetechSong()
            await fetechPlaylist()
            fetechRrecommand()
            loadCustiomizedPlaylist()
        }
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
                    recommandStation = allStations
                }catch{
                    return
                }
            default:
                return
            }
        }
    }
    
    func findPlaylistByID(id:Playlist.ID)async ->Playlist?{
        
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
    
//    func syncfindPlaylistByID(id:Playlist.ID)->Playlist{
//        Task{
//            return findPlaylistByID(id:id)
//        }
//    }
    
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
            await fetechPlaylist()
            
        }
    }
    
    func saveCustiomizedPlaylist(){
        do{
            let data = try JSONEncoder().encode(editablePlaylistID)
            UserDefaults.standard.set(data,forKey: "CustiomizedPlaylistTest")
        }catch{
            return
        }
    }
}
