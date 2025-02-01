//
//  HowHeardPage.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//

import SwiftUI

struct HowHeardPage: View {
    @Binding var selectedHowHeard: String?
    var nextPage: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("How did you hear about us?")
                .font(.headline)
                .padding()

            ForEach(howHeardOptions, id: \.self) { option in
                HStack {
                    Text(option)
                        .font(.body)
                    Spacer()
                    Image(systemName: selectedHowHeard == option ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedHowHeard == option ? .green : .gray)
                        .onTapGesture {
                            selectedHowHeard = option
                        }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
            }

            Spacer()

            Button(action: nextPage) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}
