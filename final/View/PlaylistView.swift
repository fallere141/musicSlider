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
    @State var showingHelpAlert = false
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
                        //                    Text(playlist.id.rawValue)
                        Spacer()
                        AsyncImage(url: playlist.artwork?.url(width: 50, height: 50))
                        {
                            image in image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60,height: 60,alignment: .center)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }placeholder: {
                            Image("DefaultPlaylist")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        //                        Button("delete"){
                        //                            print(playlist)
                        //                            musicData.shared.deletePlaylist(id: playlist.id)
                        //                        }
                        
                    }                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if(musicData.shared.editablePlaylistID.contains(playlist.id)){
                            Button(role: .destructive) {
                                
                                print(playlist)
                                //                            musicData.shared.deletePlaylist(id: playlist.id)
                                showingHelpAlert.toggle();
                                
                            } label: {
                                Label("Recover", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
                    .alert(isPresented: $showingHelpAlert) {
                        Alert(title: Text("Cannot delete playlist in Music Slider"), message: Text("Apple Music only allow deleting playlist in their own application "), dismissButton: .default(Text("OK")))
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
        }.onChange(of: musicData.shared.editablePlaylistID) { _, _ in
            customizedPlaylistID = musicData.shared.editablePlaylistID
        }.onChange(of: musicData.shared.playlist) { _, _ in
            playlists = musicData.shared.playlist.compactMap({$0})
        }
    }
}


struct FormView: View {
    @Binding var addingSheet: Bool
    @Binding var userInput: String
    @Binding var detail: String
    @State private var isSaving: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add a organized playlist")) {
                    TextField("Title", text: $userInput)
                    TextField("Detail", text: $detail)
                }
                
                Section {
                    HStack {
                        Button("Save") {
                            savePlaylist()
                        }
                        .disabled(isSaving)
                        
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
                }
            }
            .navigationTitle("Add a organized playlist")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        addingSheet.toggle()
                    }
                }
            }
        }
    }
    
    func savePlaylist() {
        isSaving = true
        Task {
            do {
                let response = try await MusicLibrary.shared.createPlaylist(name: userInput, description: detail)
                musicData.shared.editablePlaylistID.append(response.id)
                musicData.shared.saveCustiomizedPlaylist()
                musicData.shared.loadCustiomizedPlaylist()
                DispatchQueue.main.async {
                    addingSheet.toggle()
                    isSaving = false
                }
            } catch {
                DispatchQueue.main.async {
                    isSaving = false
                    print("Failed to create playlist: \(error.localizedDescription)")
                }
            }
        }
    }
}


#Preview {
    playListView()
}
