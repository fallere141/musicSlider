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
    
    
    
    func fetechData(){
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
