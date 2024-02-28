//
//  PlaylistView.swift
//  final
//
//  Created by Fallere141 on 2/26/24.
//


import SwiftUI
import MusicKit


//struct playListItem:Identifiable,Codable{
//    var id=UUID()
//    let name:String
//    let playlist:Playlist
//
//
//
//}

struct playListView: View {
    //    @State var playlists=[Playlist]()
    @State private var selection = "All"
    @State var addingSheet = false
    @State var userInput: String = ""
    @State var detail: String = ""
    @State var customizedPlaylistID:[Playlist.ID] = []
    //    var playlistsGet:[Playlist]
    //    {
    //        switch selection{
    //        case "All":
    //            return musicData.shared.playlist.compactMap({$0})
    //        default:
    //            return musicData.shared.playlist.filter({ musicData.shared.editablePlaylistID.contains($0.id)}).compactMap({$0})
    //        }
    //    }
    
    @State var playlists:[Playlist] = []
    
    
    
    
    var body: some View {
        
        NavigationStack{
            Picker("Select", selection: $selection) {
                Text("All").tag("All")
                Text("Customized").tag("Customized")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            List(
                (selection == "All") ?
                playlists : playlists.filter({ customizedPlaylistID.contains($0.id)}).compactMap({$0})
            ){
                playlist in
                NavigationLink(value: playlist){
                    HStack{
                        Text(playlist.name)
//                        Text(addingSheet ? "true"  : "false" )
                        Spacer()
                        AsyncImage(url: playlist.artwork?.url(width: 50, height: 50))
                        {
                            image in image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60,height: 60,alignment: .center)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        
                    placeholder: {
                        ProgressView()
                    } .frame(width: 75,height: 75,alignment: .center)
                        
                        
                    }.onTapGesture {
                        //                    showSongFromPlaylist(playlist: playlist)
                        //                    NavigationLink
                    }
                }
                
            }
            .navigationDestination(for: Playlist.self) { item in
                TrackView(playlist: item)
            }.toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if selection != "All" {
                        Button("add playlist") {
                            addingSheet.toggle()
                            
                            playlists = musicData.shared.playlist.compactMap({$0})
                            customizedPlaylistID = musicData.shared.editablePlaylistID
                            
                        }
                    }
                    // a transparent button just to make to sections looks the same
                    else{
                        Button("add playlist") {
                            
                        }.opacity(0)
                    }
                }
            }
            .sheet(isPresented: $addingSheet) {
                FormView(addingSheet: $addingSheet,userInput: $userInput,detail:$detail)
            }
        }.onAppear(){
            playlists = musicData.shared.playlist.compactMap({$0})
            customizedPlaylistID = musicData.shared.editablePlaylistID
        }.refreshable {
            playlists = musicData.shared.playlist.compactMap({$0})
            customizedPlaylistID = musicData.shared.editablePlaylistID
        }
    }
}

struct FormView: View {
    
    @Binding var addingSheet: Bool
    @Binding var userInput: String
    @Binding var detail: String
    
    @State var selectColorFrom = ["red", "green", "yellow", "blue"]
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("DDL content")) {
                    TextField("title",text: $userInput)
                    TextField("detail",text: $detail)
                }
                
                
                
                Section {
                    Button("Save") {
                        Task{
                            do{
                                let response = try await MusicLibrary.shared.createPlaylist(name: userInput, description: detail)
                                musicData.shared.editablePlaylistID.append(response.id)
                                musicData.shared.saveCustiomizedPlaylist()
                                musicData.shared.loadCustiomizedPlaylist()
                                
                            }
                            catch{
                                //                                musicData.shared.saveCustiomizedPlaylist()
                            }
                        }
//                        musicData.shared.saveCustiomizedPlaylist()
//                        musicData.shared.loadCustiomizedPlaylist()
                        addingSheet.toggle()
                    }
                }
            }
            .navigationTitle("Add a new DDL")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        addingSheet.toggle()
                    }
                }
            }
        }
    }
}

#Preview {
    playListView()
}
