//
//  HotelApp.swift
//  Demo
//
//  Created by Riddhi Tharewal on 14/04/25.
//



//
//  HotelApp.swift
//  Example
//
//  Created by Riddhi Tharewal on 12/03/25.
//


import SwiftUI

struct HotelApp: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HeaderSection()
                SpecialOffersSection()
                GymSection()
                DiscoverSection()
                FooterSection()
            }
            .background(Color(hex: "#F7F2EF"))
        }
    }
}

struct HeaderSection: View {
    var body: some View {
        ZStack {
            Image("hotel5")
                .resizable()
                .scaledToFill()
                .frame(height: 550)
                .clipped()
            
            VStack {
                Spacer().frame(height: 60)
                Text("Contoso Hotels")
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("Luxury Business Hotels")
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Button(action: {
                    // TODO: Handle click
                }) {
                    Text("Book Your Stay")
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Color(hex: "#8B4513"))
                        .cornerRadius(10)
                }
            }
            .padding(20)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

struct SpecialOffersSection: View {
    let offers = [
        Offer(title: "Dine and Stay Package", description: "Enjoy luxury dining and stay with exclusive discounts.", imageName: "family_in_dinner_celebration"),
        Offer(title: "City Tour Package", description: "Explore the city's top attractions with guided tours.", imageName: "person_rolling_luggage"),
        Offer(title: "Hotel and Flight Package", description: "Book your hotel and flight together for amazing savings.", imageName: "hotel2")
    ]
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Special Offers")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#333333"))
                .multilineTextAlignment(.center)
            
            ForEach(offers, id: \.title) { offer in
                OfferItem(offer: offer)
            }
        }
        .padding(20)
        .background(Color(hex: "#F7F2EF"))
    }
}

struct OfferItem: View {
    let offer: Offer
    
    var body: some View {
        VStack {
            Image(offer.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 200)
                .cornerRadius(10)
                .shadow(radius: 4)
            
            Text(offer.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#333333"))
                .multilineTextAlignment(.center)
               
            
            Text(offer.description)
                .font(.body)
                .foregroundColor(Color(hex: "#666666"))
               .multilineTextAlignment(.center)
               .frame(width: 200)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 4)
    }
}

struct GymSection: View {
    var body: some View {
        ZStack {
            Image("luxury_gym")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
            
            VStack {
                Text("Explore Our Luxury Gym")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("Our state-of-the-art gym is equipped with the latest fitness equipment...")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 200)
                Button(action: {
                    // TODO: Handle click
                }) {
                    Text("Join Now")
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Color(hex: "#8B4513"))
                        .cornerRadius(10)
                }
            }
            .padding(16)
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }
}

struct DiscoverSection: View {
    let places = [
        Place(name: "Bugle Rock Park", imageName: "buggle_rock_prk"),
        Place(name: "Planetarium", imageName: "planetarium"),
        Place(name: "Museum", imageName: "museum")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Discover Bangalore")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#333333"))
                .multilineTextAlignment(.center)
            
            ForEach(places, id: \.name) { place in
                PlaceItem(place: place)
            }
        }
        .padding(16)
        .background(Color(hex: "#F7F2EF"))
    }
}

struct PlaceItem: View {
    let place: Place
    
    var body: some View {
        VStack {
            Image(place.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .cornerRadius(10)
                .shadow(radius: 4)
            
            Text(place.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#333333"))
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 4)
    }
}

struct FooterSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Location")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#333333"))
            Text("123 Luxury St, Downtown City, Country 12345")
                .font(.body)
                .foregroundColor(Color(hex: "#555555"))
            
            Text("Business")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#333333"))
            Text("About Us, Careers, Press, Contact Us")
                .font(.body)
                .foregroundColor(Color(hex: "#555555"))
            
            Text("Social")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#333333"))
            Text("Facebook, Twitter, Instagram")
                .font(.body)
                .foregroundColor(Color(hex: "#555555"))
        }
        .padding(16)
        .background(Color(hex: "#F7F2EF"))
    }
}

struct Offer {
    let title: String
    let description: String
    let imageName: String
}

struct Place {
    let name: String
    let imageName: String
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.index(hex.startIndex, offsetBy: 1)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            .sRGB,
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0,
            opacity: 1.0
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
