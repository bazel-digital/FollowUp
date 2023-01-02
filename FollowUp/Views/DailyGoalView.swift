//
//  DailyGoalView.swift
//  FollowUp
//
//  Created by Aaron Baw on 13/10/2022.
//

import SwiftUI

struct DailyGoalView: View {
    
    var followUps: Int
    var dailyGoal: Int? = nil
    var cornerRadius: CGFloat = Constant.cornerRadius

    // MARK: - Computed Properties
    var percentageCompletion: Float? {
        guard let dailyGoal = dailyGoal else { return nil }
        return Float(followUps) / Float(dailyGoal)
    }

    var totalFollowUpsString: String {
        if let dailyGoal = dailyGoal {
            return "\(followUps)/\(dailyGoal) Follow Ups"
        } else {
            return "\(followUps) Follow Ups"
        }
    }
    
    var dailyGoalProgressView: some View {
        VStack(alignment: .leading) {
            HStack {
                Label(title: {
                    Text(totalFollowUpsString)
                }, icon: {
                    Image(icon: .personWithCheckmark)
                })
                .font(.title3)
                .fontWeight(.semibold)
                Spacer()
                Text("Today")
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            if let percentageCompletion = percentageCompletion {
                ProgressView(value: percentageCompletion)
                    .animation(.easeInOut, value: percentageCompletion)
            }
        }
    }
    
    var goalAchievedView: some View {
        VStack {
            Label(title: {
                Text("You met your daily Follow Up Goal!")
            }, icon: {
                Image(icon: .partyPopper)
            })
            Text("\(dailyGoal ?? 0) Follow UPs")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .fontWeight(.medium)
        
    }

    var body: some View {
        Group {
            if followUps >= (dailyGoal ?? .max) {
                goalAchievedView
            } else {
                dailyGoalProgressView
            }
        }
        .frame(maxWidth: .greatestFiniteMagnitude)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(cornerRadius)
    }
}

struct DailyGoalView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
        DailyGoalView(followUps: 4, dailyGoal: 6)
            .padding()
            
        }.background(Color.secondary)
    }
}
