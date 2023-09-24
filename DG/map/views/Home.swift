//
//  Home.swift
//  DG
//
//  Created by Scott McGhie on 2023-08-29.
//

import SwiftUI
import CoreLocation
import MapKit


struct Home: View {
    @State var locationManager = CLLocationManager()
    @ObservedObject var queryArt: QueryArt
    @StateObject var vm = MapViewModel()
    @EnvironmentObject var userID: UserMonitor

    var username: UserProfile?
    
    var body: some View {
        ZStack{
            
            MapView()
                .environmentObject(vm)
                .ignoresSafeArea(.all, edges: .all)
                .onReceive(vm.$galleries, perform: { update in
                    if !update.isEmpty {
                        vm.selectPlace(place: update.first!)
                    }
                })
            
            VStack(spacing: 0){
                header
                    .padding()

                Spacer()
                ZStack{
                    ForEach(vm.galleries){ location in
                        if vm.mapLocation == location{
                            LocationPreviewView(queryArt: queryArt, location: location)
                                .environmentObject(vm)
                                .environmentObject(userID)
                                .padding()
                                .shadow(color: Color.black.opacity(0.3), radius: 20)
                                .transition(.asymmetric(insertion: .move(edge:.trailing), removal: .move(edge: .leading)))
                        }
                    }
                }
            }
            Spacer()
            VStack{
                Button(action: vm.focusLocation, label: {
                    Image(systemName: "location.fill")
                        .font(.title2)
                        .padding(10)
                        .background(Color.primary)
                        .clipShape(Circle())
                })
                Button(action: vm.updateMapType, label: {
                    Image(systemName: vm.mapType ==
                        .standard ? "network" : "map")
                        .font(.title2)
                        .padding(10)
                        .background(Color.primary)
                        .clipShape(Circle())
                })
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
            
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            locationManager.delegate = vm
            locationManager.requestWhenInUseAuthorization()
            queryArt.getARGalleries(artistId: username!.id)
        })
        .onReceive(queryArt.$arGalleries, perform: { update in
            if update != nil {
                vm.galleries = update!
                vm.updateLocations()
            }
        })
        .onDisappear(perform: {
            vm.mapView.removeAnnotations(vm.mapView.annotations)
        })
        .alert(isPresented: $vm.permissionDenied) {
            Alert(title: Text("Permission Denied"), message:
            Text("Please Enable Permission In app Settings"),
                  dismissButton: .default(Text("Go to settings"),
                    action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
        }
        .preferredColorScheme(.dark)
    }
}

//struct Home_Previews: PreviewProvider {
//    static var previews: some View {
//        Home()
//            .environmentObject(LocationsViewModel())
//    }
//}

extension Home{
    
    private var header: some View{
        VStack {
            Button(action: vm.toggleLocationsList) {
                if let response = queryArt.arGalleries{
                    Text(vm.mapLocation!.galleryName)
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .animation(.none, value: vm.mapLocation)
                        .overlay(alignment: .leading){
                            Image(systemName: "arrow.down")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding()
                                .rotationEffect(Angle(degrees:
                                                        vm.showLocationsList ? 180:0))
                        }
                }
            }
            if vm.showLocationsList {
                ListView()
                    .environmentObject(vm)
            }
        }
        .background(.thickMaterial)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x:0, y: 15)
    }
    
}
