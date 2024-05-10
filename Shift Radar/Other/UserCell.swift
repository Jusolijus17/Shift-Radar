//
//  UserCell.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-05-09.
//

import SwiftUI

struct UserCell: View {
    @Binding var user: UserData
    
    var body: some View {
        HStack {
            ProfileImage(image: .constant(nil), imageURL: user.profileImageUrl, width: 50, height: 50) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading) {
                Text("\(user.firstName) \(user.lastName)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                HStack(spacing: 0) {
                    Text("#")
                        .bold()
                    Text(user.employeeNumber)
                }
                .foregroundStyle(.accent)
            }
            Spacer()
            Group {
                if (user.phoneNumber != nil) {
                    Image(systemName: "phone.fill")
                }
                Image(systemName: "message.fill")
            }
            .foregroundStyle(.secondary)
            .font(.title2)
        }
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .stroke(Color.accentColor.opacity(0.5))
        }
    }

}

#Preview {
    UserCell(user: .constant(UserData.dummyUser()))
}
