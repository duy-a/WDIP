//
//  CarListEmptyView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 27/7/25.
//

import SwiftUI

struct CarListEmptyView: View {
    
    var buttonAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Label("Car Icon", systemImage: "car.badge.gearshape")
                .labelStyle(.iconOnly)
                .frame(width: 80, height: 80)
                .font(.largeTitle)
                .padding(15)
                .glassEffect(in: .circle)

            VStack {
                Text("No vehicles")
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("We need at least 1 vehicle to track. Add a new vehicle now by pressing a button below")
                    .multilineTextAlignment(.center)
            }
            
            Button {
                buttonAction()
            } label: {
                Label("Add new car", systemImage: "car")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.extraLarge)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    CarListEmptyView {
        //
    }
}
