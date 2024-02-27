////
////  DetailView.swift
////  final
////
////  Created by Yun Liu on 2/26/24.
////
//
//import SwiftUI
//
//struct DetailView: View {
//    @EnvironmentObject var dataModel: DataModel
//    @State var item: Item?
//    @State private var offset = CGSize.zero
//    @State private var isRemoved = false
//    @State private var showingHelpAlert = false
//    
//    var body: some View {
//        NavigationView {
//            GeometryReader { geometry in
//                VStack {
//                    AsyncImage(url: item?.url) { phase in
//                        switch phase {
//                        case .empty:
//                            ProgressView()
//                        case .success(let image):
//                            image
//                                .resizable()
//                                .scaledToFit()
//                        case .failure:
//                            Image(systemName: "photo")
//                                .resizable()
//                                .scaledToFit()
//                        @unknown default:
//                            EmptyView()
//                        }
//                    }
//                    .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
//                    .opacity(isRemoved ? 0 : 1)
//                    .offset(y: offset.height)
//                    .animation(.easeInOut, value: offset)
//                    .gesture(
//                        DragGesture()
//                            .onChanged { gesture in
//                                self.offset = gesture.translation
//                            }
//                            .onEnded { gesture in
//                                handleGestureEnd(gesture)
//                            }
//                    )
//                    .onChange(of: item) { _ in
//                        self.offset = .zero
//                        self.isRemoved = false
//                    }
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack {
//                            ForEach(dataModel.folders) { folder in
//                                VStack {
//                                    Image(systemName: "folder")
//                                        .resizable()
//                                        .frame(width: 50, height: 40)
//                                        .padding()
//                                        .onTapGesture {
//                                            if let currentItem = item {
//                                                dataModel.addItemToFolder(currentItem, folderName: folder.name)
//                                            }
//                                        }
//                                    Text(folder.name)
//                                }
//                            }
//                        }
//                    }
//                    .padding()
//                }
//            }
//            .navigationBarItems(leading: Button(action: {
//                showingHelpAlert = true
//            }) {
//                Text("Help")
//            }, trailing: NavigationLink(destination: ContentView().environmentObject(dataModel)) {
//                Text("Images")
//            })
//            .alert(isPresented: $showingHelpAlert) {
//                Alert(title: Text("Help"), message: Text("Slide left to switch，Slide up to detete，Slide down to like"), dismissButton: .default(Text("OK")))
//            }
//            .navigationBarTitle("ImageSlider", displayMode: .inline)
//        }
//    }
//    
//    private func handleGestureEnd(_ gesture: DragGesture.Value) {
//        let horizontalAmount = gesture.translation.width
//        let verticalAmount = gesture.translation.height
//        
//        let nextItem = determineNextItem()
//        
//        if abs(horizontalAmount) > abs(verticalAmount) {
//            if horizontalAmount < 0 {
//                withAnimation {
//                    isRemoved = true
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//                    self.item = nextItem
//                }
//            }
//        } else {
//            if verticalAmount < 0 {
//                withAnimation {
//                    isRemoved = true
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//                    dataModel.deleteItem(item!)
//                    self.item = nextItem
//                }
//            } else {
//                dataModel.toggleFavorite(item!)
//            }
//        }
//        
//        self.offset = .zero
//    }
//
//    private func determineNextItem() -> Item {
//        guard let currentIndex = dataModel.items.firstIndex(where: { $0.id == self.item!.id }) else {
//            return self.item!
//        }
//        
//        let nextIndex = currentIndex + 1 < dataModel.items.count ? currentIndex + 1 : 0
//        return dataModel.items[nextIndex]
//    }
//}
//
//
//struct ImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        if let url = Bundle.main.url(forResource: "mushy1", withExtension: "jpg") {
//            DetailView(item: Item(url: url))
//        }
//    }
//}
//
